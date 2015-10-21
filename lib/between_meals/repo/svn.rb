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
require 'between_meals/repo'
require 'between_meals/changeset'
require 'mixlib/shellout'
require 'between_meals/repo/svn/cmd'

module BetweenMeals
  class Repo
    class Svn < BetweenMeals::Repo
      def setup
        @bin = 'svn'
        @cmd = BetweenMeals::Repo::Svn::Cmd.new(
          :bin => @bin,
          :cwd => '/tmp',
          :logger => @logger,
        )
      end

      def exists?
        Dir.exists?(Pathname.new(@repo_path).join('.svn'))
      end

      def head_rev
        @cmd.info(@repo_path).stdout.each_line do |line|
          m = line.match(/Last Changed Rev: (\d+)$/)
          return m[1] if m
        end
      end

      def latest_revision
        @cmd.info(@repo_path).stdout.each_line do |line|
          m = line.match(/Revision: (\d+)$/)
          return m[1] if m
        end
      end

      def checkout(url)
        @cmd.co(url, @repo_path)
      end

      # Return files changed between two revisions
      def changes(start_ref, end_ref)
        valid_ref?(start_ref)
        valid_ref?(end_ref) if end_ref

        @logger.info("Diff between #{start_ref} and #{end_ref}")
        changes = @cmd.diff(start_ref, end_ref, @repo_path).stdout

        begin
          parse_status(changes).compact
        rescue => e
          @logger.error(
            'Something went wrong. Please please report this output.'
          )
          @logger.error(e)
          stdout.lines.each do |line|
            @logger.error(line.strip)
          end
          exit(1)
        end
      end

      def update
        @cmd.cleanup(@repo_path)
        @cmd.revert(@repo_path)
        @cmd.update(@repo_path)
      end

      def files
        @cmd.ls.stdout.split("\n").map do |x|
          { :path => x, :status => :created }
        end
      end

      def upstream?
      end

      def valid_ref?(ref)
        @cmd.info_r(ref, @repo_path)
      rescue
        raise Changeset::ReferenceError
      end

      private

      def parse_status(changes)
        # http://svnbook.red-bean.com/en/1.0/re26.html
        changes.lines.map do |line|
          case line
          when (/^([\w ])\w?\s+(\S+)$/)
            {
              :status => Regexp.last_match(1) == 'D' ? :deleted : :modified,
              :path => Regexp.last_match(2).sub("#{@repo_path}/", ''),
            }
          else
            fail 'No match'
          end
        end
      end
    end
  end
end
