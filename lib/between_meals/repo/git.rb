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

# Require openssl in order to make rugged work reliably
require 'openssl'

require 'rugged'
require 'mixlib/shellout'
require 'between_meals/changeset'
require 'between_meals/repo/git/cmd'

module BetweenMeals
  class Repo
    class Git < BetweenMeals::Repo
      def setup
        if File.exists?(File.expand_path(@repo_path))
          begin
            @repo = Rugged::Repository.new(File.expand_path(@repo_path))
          # rubocop:disable Lint/RescueWithoutErrorClass
          rescue
            @repo = nil
          end
        else
          @repo = nil
        end
        @bin = 'git'
        @cmd = BetweenMeals::Repo::Git::Cmd.new(
          :bin => @bin,
          :cwd => @repo_path,
          :logger => @logger,
        )
      end

      def exists?
        !@repo.nil?
      end

      def head_rev
        @repo.head.target.oid
      end

      def last_msg
        @repo.head.target.message
      end

      def last_msg=(msg)
        @repo.head.target.amend(
          {
            :message => msg,
            :update_ref => 'HEAD',
          },
        )
      end

      def last_author
        @repo.head.target.to_hash[:author]
      end

      def head_parents
        @repo.head.target.parents.map do |x|
          { :rev => x.tree.oid, :time => x.time }
        end
      end

      def checkout(url)
        @cmd.clone(url, @repo_path)
        @repo = Rugged::Repository.new(File.expand_path(@repo_path))
      end

      # Return files changed between two revisions
      def changes(start_ref, end_ref)
        valid_ref?(start_ref)
        valid_ref?(end_ref) if end_ref
        stdout = @cmd.diff(start_ref, end_ref).stdout
        begin
          parse_status(stdout).compact
        # rubocop:disable Lint/RescueWithoutErrorClass
        rescue => e
          # We've seen some weird non-reproducible failures here
          @logger.error(
            'Something went wrong. Please report this output.',
          )
          @logger.error(e)
          stdout.lines.each do |line|
            @logger.error(line.strip)
          end
          exit(1)
        end
      end

      def update
        @cmd.pull.stdout
      end

      # Return all files
      def files
        @repo.index.map { |x| { :path => x[:path], :status => :created } }
      end

      def upstream?(rev, master = 'remotes/trunk')
        if @cmd.merge_base(rev, master).stdout.strip == rev
          return true
        end
        return false
      # rubocop:disable Lint/RescueWithoutErrorClass
      rescue
        return false
      end

      def status
        @cmd.status.stdout.strip
      end

      def name
        @cmd.config('user.name').stdout.strip
      end

      def email
        @cmd.config('user.email').stdout.strip
      end

      def valid_ref?(ref)
        unless @repo.exists?(ref)
          fail Changeset::ReferenceError
        end
      end

      private

      def parse_status(changes)
        # man git-diff-files
        # Possible status letters are:
        #
        # A: addition of a file
        # C: copy of a file into a new one
        # D: deletion of a file
        # M: modification of the contents or mode of a file
        # R: renaming of a file
        # T: change in the type of the file
        # U: file is unmerged (you must complete the merge before it can
        #    be committed)
        # X: "unknown" change type (most probably a bug, please report it)

        # rubocop:disable MultilineBlockChain
        changes.lines.map do |line|
          case line
          when /^A\s+(\S+)$/
            # A path
            {
              :status => :modified,
              :path => Regexp.last_match(1),
            }
          when /^C(?:\d*)\s+(\S+)\s+(\S+)/
            # C<numbers> path1 path2
            {
              :status => :modified,
              :path => Regexp.last_match(2),
            }
          when /^D\s+(\S+)$/
            # D path
            {
              :status => :deleted,
              :path => Regexp.last_match(1),
            }
          when /^M(?:\d*)\s+(\S+)$/
            # M<numbers> path
            {
              :status => :modified,
              :path => Regexp.last_match(1),
            }
          when /^R(?:\d*)\s+(\S+)\s+(\S+)/
            # R<numbers> path1 path2
            [
              {
                :status => :deleted,
                :path => Regexp.last_match(1),
              },
              {
                :status => :modified,
                :path => Regexp.last_match(2),
              },
            ]
          when /^T\s+(\S+)$/
            # T path
            [
              {
                :status => :deleted,
                :path => Regexp.last_match(1),
              },
              {
                :status => :modified,
                :path => Regexp.last_match(1),
              },
            ]
          else
            fail 'Failed to parse repo diff line.'
          end
        end.flatten.map do |x|
          {
            :status => x[:status],
            :path => x[:path].sub("#{@repo_path}/", ''),
          }
        end
        # rubocop:enable MultilineBlockChain
      end
    end
  end
end
