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

require 'logger'

module BetweenMeals
  class Cmd
    attr_accessor :bin

    def initialize(params)
      @bin = params[:bin] || fail
      @cwd = params[:cwd] || Dir.pwd
      @logger = params[:logger] || Logger.new(STDOUT)
    end

    def cmd(params, cwd = nil)
      cwd ||= File.expand_path(@cwd)
      cmd = "#{@bin} #{params}"
      @logger.info("Running \"#{cmd}\"")
      c = Mixlib::ShellOut.new(
        cmd,
        :cwd => cwd,
        :env => {
          # macOS needs /usr/local/bin as hg cannot be installed in /bin or
          # /usr/bin
          'PATH' => '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin',
        },
      )
      c.run_command
      if c.error?
        # Let's make sure the error goes to the logs
        @logger.error("#{@bin} failed: #{c.format_for_exception}")
        # if our logger is STDOUT, we'll double log when we throw
        # the exception, but that's OK
        c.error!
      end
      c
    end
  end
end
