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

require 'pathname'
require 'mixlib/shellout'
require 'between_meals/changeset'
require 'between_meals/repo/hg/cmd'

module BetweenMeals
  class Repo
    class Hg < BetweenMeals::Repo
      def setup
        @bin = 'hg'
        @cmd = BetweenMeals::Repo::Hg::Cmd.new(
          :bin => @bin,
          :cwd => @repo_path,
          :logger => @logger,
        )
      end

      def exists?
        Dir.exists?(Pathname.new(@repo_path).join('.hg'))
      end

      def head_rev
        @cmd.log('node').stdout
      end

      def checkout(url)
        @cmd.clone(url, @repo_path)
      end

      # Return files changed between two revisions
      def changes(start_ref, end_ref)
        valid_ref?(start_ref)
        valid_ref?(end_ref) if end_ref
        stdout = @cmd.status(start_ref, end_ref).stdout
        begin
          parse_status(stdout).compact
        rescue StandardError => e
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
      rescue StandardError => e
        @logger.error('Something went wrong with hg!')
        @logger.error(e)
        raise
      end

      # Return all files
      def files
        @cmd.manifest.stdout.split("\n").map do |x|
          { :path => x, :status => :created }
        end
      end

      def head_parents
        [{
          :time => Time.parse(@cmd.log('date|isodate', 'master').stdout),
          :rev => @cmd.log('node', 'master').stdout,
        }]
      rescue StandardError
        [{
          :time => nil,
          :rev => nil,
        }]
      end

      def last_author
        [
          /^.*<(.*)>$/,
          /^(.*@.*)$/,
        ].each do |re|
          m = @cmd.log('author').stdout.match(re)
          return { :email => m[1] } if m
        end
        return { :email => nil }
      end

      def last_msg
        @cmd.log('desc').stdout
      rescue StandardError
        nil
      end

      def last_msg=(msg)
        if last_msg.strip != msg.strip
          @cmd.amend(msg.strip)
        end
      end

      def email
        username[2]
      rescue StandardError
        nil
      end

      def name
        username[1]
      rescue StandardError
        nil
      end

      def status
        @cmd.status.stdout
      end

      def upstream?(rev)
        # Check if commit is an ancestor of master
        # Returns the diff if common ancestor is found,
        # returns nothing if not
        if @cmd.rev("'ancestor(master,#{rev}) & #{rev}'").stdout.empty?
          return false
        else
          return true
        end
      end

      def valid_ref?(ref)
        @cmd.rev(ref)
        return true
      rescue StandardError
        raise Changeset::ReferenceError
      end

      private

      def username
        @cmd.username.stdout.lines.first.strip.match(/^(.*?)(?:\s<(.*)>)?$/)
      end

      def parse_status(changes)
        # The codes used to show the status of files are:
        #
        #  M = modified
        #  A = added
        #  R = removed
        #  C = clean
        #  ! = missing (deleted by non-hg command, but still tracked)
        #  ? = not tracked
        #  I = ignored
        #    = origin of the previous file (with --copies)

        changes.lines.map do |line|
          case line
          when /^A (.+)$/
            {
              :status => :added,
              :path => Regexp.last_match(1),
            }
          when /^C (.+)$/
            {
              :status => :clean,
              :path => Regexp.last_match(1),
            }
          when /^R (.+)$/
            {
              :status => :deleted,
              :path => Regexp.last_match(1),
            }
          when /^M (.+)$/
            {
              :status => :modified,
              :path => Regexp.last_match(1),
            }
          when /^! (.+)$/
            {
              :status => :missing,
              :path => Regexp.last_match(1),
            }
          when /^\? (.+)$/
            {
              :status => :untracked,
              :path => Regexp.last_match(1),
            }
          when /^I (.+)$/
            {
              :status => :ignored,
              :path => Regexp.last_match(1),
            }
          else
            fail 'Failed to parse repo diff line.'
          end
        end
      end
    end
  end
end
