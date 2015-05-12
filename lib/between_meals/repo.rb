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
require 'between_meals/repo/svn'
require 'between_meals/repo/hg'

module BetweenMeals
  # Local checkout wrapper
  class Repo
    attr_reader :repo_path
    attr_writer :bin

    def initialize(repo_path, logger)
      @repo_path = repo_path
      @logger = logger
      @repo = nil
      @bin = nil
      setup
    end

    def self.get(type, repo_path, logger)
      repo_path = ::Pathname.new(repo_path).realpath
      case type
      when 'auto'
        [
          BetweenMeals::Repo::Git,
          BetweenMeals::Repo::Hg,
          BetweenMeals::Repo::Svn,
        ].each do |repo|
          begin
            return repo.new(repo_path, logger)
          rescue
          end
        end
        fail "Could not determine repo type"
      when 'svn'
        BetweenMeals::Repo::Svn.new(repo_path, logger)
      when 'git'
        BetweenMeals::Repo::Git.new(repo_path, logger)
      when 'hg'
        BetweenMeals::Repo::Hg.new(repo_path, logger)
      else
        fail "Do not know repo type #{type}"
      end
    end

    def exists?
      fail "#{__method__} not implemented"
    end

    def status
      fail "#{__method__} not implemented"
    end

    def setup
      fail "#{__method__} not implemented"
    end

    def head_rev
      fail "#{__method__} not implemented"
    end

    def head_msg
      fail "#{__method__} not implemented"
    end

    def head_msg=
      fail "#{__method__} not implemented"
    end

    def head_parents
      fail "#{__method__} not implemented"
    end

    def latest_revision
      fail "#{__method__} not implemented"
    end

    def create(_url)
      fail "#{__method__} not implemented"
    end

    # Return files changed between two revisions
    def changes(_start_ref, _end_ref)
      fail "#{__method__} not implemented"
    end

    def update
      fail "#{__method__} not implemented"
    end

    # Return all files
    def files
      fail "#{__method__} not implemented"
    end

    def latest_revision
      fail "#{__method__} not implemented"
    end

    def head
      fail "#{__method__} not implemented"
    end

    def checkout
      fail "#{__method__} not implemented"
    end

    def update
      fail "#{__method__} not implemented"
    end

    def last_author
      fail "#{__method__} not implemented"
    end

    def last_msg
      fail "#{__method__} not implemented"
    end

    def last_msg=
      fail "#{__method__} not implemented"
    end

    def name
      fail "#{__method__} not implemented"
    end

    def email
      fail "#{__method__} not implemented"
    end
  end
end
