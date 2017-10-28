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
      def self.meaningful_cookbook_file?(path)
        !explode_path(path).nil?
      end

      def self.explode_path(path)
        @cookbook_dirs.each do |dir|
          re = %r{^#{dir}/([^/]+)/.*}
          debug("[cookbook] Matching #{path} against ^#{re}")
          m = path.match(re)
          next unless m
          info("Cookbook is #{m[1]}")
          return {
            :cookbook_dir => dir,
            :name => m[1],
          }
        end
        nil
      end

      def self.symlinked_dir?(link_path)
        File.symlink?(link_path) &&
          File.directory?(File.absolute_path(link_path))
      end

      def self.map_symlinks(files)
        # For each symlink get the source path, if any files have changed under
        # the source path, fake them as coming from the symlink path. This
        # allows the normal cookbook logic to just work.
        require 'find'
        symlinks = {}
        @cookbook_dirs.each do |dir|
          dir = File.join(@repo_dir, dir)
          # Finds all symlinks in cookbook_dir
          Find.find(dir).select { |f| f if File.symlink?(f) }.each do |link|
            next if symlinks[link]
            source = File.absolute_path(link)
            repo = File.join(@repo_dir, '/')
            # maps absolute symlink path to relative source and link paths
            symlinks[link] = {
              'source' => source.gsub(repo, ''),
              'link' => link.gsub(repo, ''),
            }
          end
        end

        # Create the file hash expected for each file that is a link or coming
        # from a linked directory but fake the source path as a symlink path.
        # Hacky but works :)
        links_to_append = []
        symlinks.each do |link_abs_path, lrp| # link_relative_path
          files.each do |f|
            next unless f[:path].start_with?(lrp['source'])
            l = Marshal.load(Marshal.dump(f))
            l[:path].gsub!(lrp['source'], lrp['link'])
            # a symlink will never have trailing '/', add one.
            l[:path] += '/' if symlinked_dir?(link_abs_path)
            links_to_append << l
          end
        end
        links_to_append
      end

      def initialize(files, cookbook_dirs)
        @files = files
        @cookbook_dirs = cookbook_dirs
        @name = self.class.explode_path(files.sample[:path])[:name]
        # if metadata.rb is being deleted
        #   cookbook is marked for deletion
        # otherwise it was modified
        #   and will be re-uploaded
        if files.
           select { |x| x[:status] == :deleted }.
           map do |x|
             x[:path].match(
               %{^(#{cookbook_dirs.join('|')})/[^/]+/metadata\.rb$},
             )
           end.
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
        # require 'pry'; binding.pry if track_symlinks
        list += map_symlinks(list) if track_symlinks
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
            BetweenMeals::Changes::Cookbook.new(change, @cookbook_dirs)
          end
        end.compact
        # rubocop:enable MultilineBlockChain
      end
    end
  end
end
