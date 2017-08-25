# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

# Copyright 2013-present Facebook
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# rubocop:disable ClassVars
module BetweenMeals
  module Changes
    # Changeset aware cookbook
    class Cookbook < Change
      def self.which_cookbook_dir?(path)
        @cookbook_dirs.each do |dir|
          # a symlink will never have trailing '/', add one.
          path += '/' if @track_symlinks && symlinked_dir?(path)
          re = %r{^#{dir}/([^/]+)/.*}
          m = path.match(re)
          debug("[cookbook] #{path} meaningful? [#{re}]: #{m}")
          next unless m
          return [dir, m[1]]
        end
        nil
      end

      def self.meaningful_cookbook_file?(path)
        return which_cookbook_dir?(path).nil? ? false : true
      end

      def self.explode_path(path)
        m = which_cookbook_dir?(path)
        return nil if m.nil?
        info("Cookbook is #{m[1]}")
        return {
          :cookbook_dir => m[0],
          :name => m[1],
        }
      end

      def self.prepend_repo?(link_path)
        return link_path if link_path.start_with?(@repo_dir)
        File.join(@repo_dir, link_path)
      end

      def self.symlinked_dir?(link_path)
        link_path = prepend_repo?(link_path)
        File.symlink?(link_path) &&
        File.directory?(symlink_absolute_path(link_path))
      end

      def self.symlink_absolute_path(link_path)
        link_path = prepend_repo?(link_path)
        File.realpath(link_path)
      end

      def self.symlinks(list)
        # For each symlink get the real path, if any files have changed under
        # the real path, fake them as coming from the symlink path. This allows
        # the normal cookbook logic to just work.
        require 'find'
        symlinks = {}
        @cookbook_dirs.each do |dir|
          dir = File.join(@repo_dir, dir)
          # Finds all symlinks in coobbookdirs
          Find.find(dir).select { |f| f if File.symlink?(f) }.each do |link|
            next if symlinks[link]
            real = symlink_absolute_path(link)
            repo = File.join(@repo_dir, '/')
            # maps all symlinks to real paths
            symlinks[link] = {
              'real' => real.gsub(repo, ''),
              'link' => link.gsub(repo, ''),
            }
          end
        end
        # Create the data hash expected for each file but fake the real path as
        # a symlink path. Hacky but works :)
        links_as_files = []
        symlinks.each do |_, link|
          list.each do |x|
            next unless x[:path].start_with?(link['real'])
            y = x
            y[:path].gsub!(link['real'], link['link'])
            links_as_files << y
          end
        end
        links_as_files
      end

      def initialize(files, cookbook_dirs, repo_dir, track_symlinks = false)
        @files = files
        @repo_dir = repo_dir
        @cookbook_dirs = cookbook_dirs
        @track_symlinks = track_symlinks
        @name = self.class.explode_path(files.sample[:path])[:name]
        # if metadata.rb is being deleted
        #   cookbook is marked for deletion
        # otherwise it was modified
        #   and will be re-uploaded
        if files.
           select { |x| x[:status] == :deleted }.
           map { |x| x[:path].match(%{.*metadata\.rb$}) }.
           compact.
           any?
          @status = :deleted
        else
          @status = :modified
        end
      end

      # Given a list of changed files
      # create a list of Cookbook objects
      def self.find(list, cookbook_dirs, logger, repo, track_symlinks = false)
        @@logger = logger
        return [] if list.nil? || list.empty?
        # rubocop:disable MultilineBlockChain
        @repo_dir = File.realpath(repo.repo_path)
        @cookbook_dirs = cookbook_dirs
        @track_symlinks = track_symlinks
        list += symlinks(list) if @track_symlinks
        list.
          group_by do |x|
          # Group by prefix of cookbok_dir + cookbook_name
          # so that we treat deletes and modifications across
          # two locations separately
          g = self.explode_path(x[:path])
          g[:cookbook_dir] + '/' + g[:name] if g
        end.
          map do |_, change|
          # Confirm we're dealing with a cookbook
          # Changes to OWNERS or other stuff that might end up
          # in [core, other, secure] dirs are ignored
          is_cookbook = change.select do |c|
            self.meaningful_cookbook_file?(c[:path])
          end.any?
          if is_cookbook
            BetweenMeals::Changes::Cookbook.new(
              change, @cookbook_dirs, @repo_dir, @track_symlinks
            )
          end
        end.compact
        # rubocop:enable MultilineBlockChain
      end
    end
  end
end
