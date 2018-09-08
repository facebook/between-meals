# frozen_string_literal: true

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

      def self.map_symlinks(files)
        # For each symlink get the source path, if any files have changed under
        # the source path, fake them as coming from the symlink path. This
        # allows the normal cookbook logic to just work.
        symlinks = {}
        @cookbook_dirs.each do |dir|
          dir = File.join(@repo_dir, dir)
          # Find symlinks in each cookbook_dir
          links = Dir.foreach(dir).select do |d|
            File.symlink?(File.join(dir, d))
          end
          links.each do |link|
            link = File.join(dir, link)
            next if symlinks[link]
            source = File.realpath(link)
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
        symlinks.each_value do |lrp| # link_abs_path, link_relative_path
          files.each do |f|
            # a symlink will never have trailing '/', add one.
            f[:path] += '/' if f[:path] == lrp['link']
            next unless f[:path].start_with?(lrp['source'])
            # This make a deep dup of the file hash
            l = Marshal.load(Marshal.dump(f))
            l[:path].gsub!(lrp['source'], lrp['link'])
            links_to_append << l
          end
        end
        links_to_append
      end

      def initialize(files, cookbook_dirs)
        @files = files
        @cookbook_dirs = cookbook_dirs
        @name = self.class.explode_path(files.sample[:path])[:name]
        # if metadata.(json|rb) is being deleted and we aren't also
        # adding/modifying one of those two,
        #   cookbook is marked for deletion
        # otherwise it was modified
        #   and will be re-uploaded
        if files.
           select { |x| x[:status] == :deleted }.
           map do |x|
             x[:path].match(
               %{^(#{cookbook_dirs.join('|')})/[^/]+/metadata\.(rb|json)$},
             )
           end.
           compact.
           any? &&
           files.reject { |x| x[:status] == :deleted }.
           map do |x|
             x[:path].match(
               %{^(#{cookbook_dirs.join('|')})/[^/]+/metadata\.(rb|json)$},
             )
           end.none?
          @status = :deleted
        else
          @status = :modified
        end
      end

      # Given a list of changed files
      # create a list of Cookbook objects
      def self.find(list, cookbook_dirs, logger, repo, track_symlinks = false)
        # rubocop:disable ClassVars
        @@logger = logger
        # rubocop:enable ClassVars
        return [] if list.nil? || list.empty?
        # rubocop:disable MultilineBlockChain
        @repo_dir = File.realpath(repo.repo_path)
        @cookbook_dirs = cookbook_dirs
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
