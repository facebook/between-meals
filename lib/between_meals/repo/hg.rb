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

require 'mixlib/shellout'
require 'between_meals/changeset'

module BetweenMeals
  # Local checkout wrapper
  class Repo
    # Hg implementation
    class Hg < BetweenMeals::Repo
      # see repo.rb for API documentation.
      def setup
        fail unless File.exist?(@repo_path + ".hg")
        @bin = 'hg'
      end

      def exists?
        # this should be better
        Dir.exists?(@repo_path)
      end

      def head_rev
        s = Mixlib::ShellOut.new(
          "#{@bin} log -r . -T '{node}'",
          :cwd => File.expand_path(@repo_path)
        ).run_command
        s.error!
        s.stdout
      end

      def checkout(url)
        s = Mixlib::ShellOut.new(
          "#{@bin} clone #{url} #{@repo_path}"
        ).run_command
        s.error!
      end

      # Return files changed between two revisions
      def changes(start_ref, end_ref)
        check_refs(start_ref, end_ref)
        cmd = "#{@bin} status --rev #{start_ref}"
        if end_ref
          cmd += " --rev #{end_ref}"
        end
        s = Mixlib::ShellOut.new(
          cmd,
          :cwd => File.expand_path(@repo_path)
        )
        s.run_command.error!
        begin
          parse_status(s.stdout).compact
        rescue => e
          # We've seen some weird non-reproducible failures here
          @logger.error(
            'Something went wrong. Please please report this output.'
          )
          @logger.error(e)
          s.stdout.lines.each do |line|
            @logger.error(line.strip)
          end
          exit(1)
        end
      end

      def update
        cmd = Mixlib::ShellOut.new(
          "#{@bin} pull --rebase",
          :cwd => File.expand_path(@repo_path)
        )
        cmd.run_command
        if cmd.exitstatus != 0
          @logger.error('Something went wrong with hg!')
          @logger.error(cmd.stdout)
          fail
        end
        cmd.stdout
      end

      # Return all files
      def files
        s = Mixlib::ShellOut.new(
          "#{@bin} manifest",
          :cwd => @repo_path
        )
        s.run_command
        s.error!
        s.stdout.split("\n").map do |x|
          { :path => x, :status => :created }
        end
      end

      def head_parents
        lines = show.stdout.lines
        time = lines.select {|line| line.match(/^date:/)}.map {|x| x.match(/^date:\s*(.*)$/)[1]}.first
        rev = lines.select {|line| line.match(/^changeset:/)}.map {|x| x.match(/^changeset:\s*(.*)$/)[1]}.first
        [{
          :time => Time.parse(time),
          :rev => rev,
        }]
      end

      def last_author
        line = show.stdout.lines.select {|line| line.match(/^user:/)}.first
        begin
          return {:email => line.match(/^user:\s*.*<(.*)@.*>$/)[1]}
        rescue
        end
        begin
          return {:email => line.match(/^user:\s*(.*)@.*$/)[1]}
        rescue
        end
        return {:email => ''}
      end

      def last_msg
        s = Mixlib::ShellOut.new(
          "#{@bin} log -l 1 --template '{desc}'"
        ).run_command
        s.stdout
      rescue
        nil
      end

      def last_msg=(msg)
        Mixlib::ShellOut.new(
          "#{@bin} commit --amend -m '#{msg}'"
        ).run_command
      end

      def email
        _username[2]
      rescue
        nil
      end

      def name
        _username[1]
      rescue
        nil
      end

      def status
        cmd = Mixlib::ShellOut.new(
          "#{@bin} status 2>&1",
          :cwd => File.expand_path(@repo_path)
        )
        cmd.run_command
        if cmd.exitstatus != 0
          @logger.error('Something went wrong with hg!')
          @logger.error(cmd.stdout)
          fail
        end
        cmd.stdout
      end

      private

      def show
        Mixlib::ShellOut.new(
          "#{@bin} show"
        ).run_command
      end

      def _username
        s = Mixlib::ShellOut.new(
          "#{@bin} config ui.username"
        ).run_command
        s.stdout.lines.first.strip.match(/^(.*?)(?:\s<(.*)>)?$/)
      end

      def check_refs(start_ref, end_ref)
        s = Mixlib::ShellOut.new(
              "#{@bin} log -r #{start_ref}",
              :cwd => @repo_path
            ).run_command
        s.error!
        if end_ref
          s = Mixlib::ShellOut.new(
                "#{@bin} log -r #{end_ref}",
                :cwd => @repo_path
              ).run_command
          s.error!
        end
      rescue
        raise Changeset::ReferenceError
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

        # rubocop:disable MultilineBlockChain
        changes.lines.map do |line|
          case line
          when /^A (\S+)$/
            {
              :status => :added,
              :path => Regexp.last_match(1)
            }
          when /^C (\S+)$/
            {
              :status => :clean,
              :path => Regexp.last_match(1)
            }
          when /^R (\S+)$/
            {
              :status => :deleted,
              :path => Regexp.last_match(1)
            }
          when /^M (\S+)$/
            {
              :status => :modified,
              :path => Regexp.last_match(1)
            }
          when /^! (\S+)$/
            {
              :status => :missing,
              :path => Regexp.last_match(1)
            }
          when /^\? (\S+)$/
            {
              :status => :untracked,
              :path => Regexp.last_match(1)
            }
          when /^I (\S+)$/
            {
              :status => :ignored,
              :path => Regexp.last_match(1)
            }
          else
            fail 'No match'
          end
        end
        # rubocop:enable MultilineBlockChain
      end
    end
  end
end
