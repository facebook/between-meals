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
    rescue
      @logger.warn("Unable to read repo from #{File.expand_path(repo_path)}")
      exit(1)
    end

    def self.get(type, repo_path, logger)
      case type
      when 'svn'
        require 'between_meals/repo/svn'
        BetweenMeals::Repo::Svn.new(repo_path, logger)
      when 'git'
        require 'between_meals/repo/git'
        BetweenMeals::Repo::Git.new(repo_path, logger)
      when 'hg'
        require 'between_meals/repo/hg'
        BetweenMeals::Repo::Hg.new(repo_path, logger)
      else
        fail "Do not know repo type #{type}"
      end
    end

    def exists?
      fail 'Not implemented'
    end

    def status
      fail 'Not implemented'
    end

    def setup
      fail 'Not implemented'
    end

    def head_rev
      fail 'Not implemented'
    end

    def head_msg
      fail 'Not implemented'
    end

    def head_msg=
      fail 'Not implemented'
    end

    def head_parents
      fail 'Not implemented'
    end

    def latest_revision
      fail 'Not implemented'
    end

    def create(_url)
      fail 'Not implemented'
    end

    # Return files changed between two revisions
    def changes(_start_ref, _end_ref)
      fail 'Not implemented'
    end

    def update
      fail 'Not implemented'
    end

    # Return all files
    def files
      fail 'Not implemented'
    end

    def latest_revision
      fail 'Not implemented'
    end

    def head
      fail 'Not implemented'
    end

    def checkout
      fail 'Not implemented'
    end

    def update
      fail 'Not implemented'
    end

    def last_author
      fail 'Not implemented'
    end

    def last_msg
      fail 'Not implemented'
    end

    def last_msg=
      fail 'Not implemented'
    end
  end
end
