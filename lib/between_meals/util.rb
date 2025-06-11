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

require 'colorize'
require 'net/http'
require 'openssl'
require 'socket'
require 'timeout'

module BetweenMeals
  # A set of simple utility functions used throughout BetweenMeals
  #
  # Feel free to use... note that if you pass in a logger once
  # you don't need to again, but be safe and always pass one in. :)

  # Util classes need class vars :)
  # rubocop:disable ClassVars
  module Util
    @@logger = nil

    def time(logger = nil)
      @@logger = logger if logger
      t0 = Time.now
      yield
      info("Executed in #{format('%.2f', Time.now - t0)}s")
    end

    def exec!(command, logger = nil, stream = nil)
      @@logger = logger if logger
      c = execute(command, stream)
      c.error!
      return c.status.exitstatus, c.stdout
    end

    def exec(command, logger = nil, stream = nil)
      @@logger = logger if logger

      c = execute(command, stream)
      return c.status.exitstatus, c.stdout
    end

    private

    def info(msg)
      @@logger&.info(msg)
    end

    def execute(command, stream)
      info("Running: #{command}")
      c = Mixlib::ShellOut.new(command, :live_stream => stream) # steep:ignore
      c.run_command
      c.stdout.lines.each do |line|
        info("STDOUT: #{line.strip}")
      end
      c.stderr.lines.each do |line|
        info("STDERR: #{line.strip.red}")
      end
      return c
    end

    def port_open?(port)
      ips = Socket.ip_address_list
      ips.map!(&:ip_address)
      ips.each do |ip|

        Timeout.timeout(1) do

          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          next

        end
      rescue Timeout::Error
        next

      end
      return false
    end

    def chef_zero_running?(port, use_ssl)
      Timeout.timeout(1) do

        http = Net::HTTP.new('localhost', port)
        if use_ssl
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        res = http.get('/')
        return res['Server'] == 'chef-zero'
      rescue StandardError
        return false

      end
    rescue Timeout::Error
      return false
    end
  end
end
# rubocop:enable ClassVars
