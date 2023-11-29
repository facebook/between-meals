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
    attr_reader :repo_path, :bin

    def initialize(repo_path, logger)
      @repo_path = repo_path
      @logger = logger
      @repo = nil
      @bin = nil
      setup
    rescue StandardError
      @logger.warn("Unable to read repo from #{File.expand_path(repo_path)}")
      exit(1)
    end

    def self.get(type, repo_path, logger)
      case type
      when 'auto'
        unless File.directory?(repo_path)
          logger.warn("#{repo_path} does not point to a repo")
          exit(1)
        end
        logger.info('Trying to detect repo type')
        {
          'Hg' => 'between_meals/repo/hg',
          'Svn' => 'between_meals/repo/svn',
          'Git' => 'between_meals/repo/git',
        }.each do |klass_name, req|
          require req
          klass = BetweenMeals::Repo.const_get(klass_name)
          r = klass.new(repo_path, logger)
          if r.exists?
            logger.info("Repo found to be #{klass.to_s.split('::').last}")
            return r
          end
        rescue StandardError
          logger.debug("Skipping #{klass}")

        end
        logger.warn("Failed detecting repo type at #{repo_path}")
        exit(1)
      when 'hg'
        require 'between_meals/repo/hg'
        BetweenMeals::Repo::Hg.new(repo_path, logger)
      when 'svn'
        require 'between_meals/repo/svn'
        BetweenMeals::Repo::Svn.new(repo_path, logger)
      when 'git'
        require 'between_meals/repo/git'
        BetweenMeals::Repo::Git.new(repo_path, logger)
      else
        fail "Do not know repo type #{type}"
      end
    end

    def bin=(bin)
      @bin = bin
      @cmd.bin = bin
    end

    def exists?
      fail "#{__method__} not implemented"
    end

    def status
      fail "#{__method__} not implemented"
    end

    # Only interesting in the case of git where we have an underlying
    # repo object courtesy of Rugged.
    def repo_object
      fail "#{__method__} not implemented"
    end

    # This method *must* succeed in the case of no repo directory so that
    # users can call `checkout`. Users may call `exists?` to find out if
    # we have an underlying repo yet.
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

    def head
      fail "#{__method__} not implemented"
    end

    def checkout
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

    def upstream?(_rev)
      fail "#{__method__} not implemented"
    end

    def valid_ref?(_rev)
      fail "#{__method__} not implemented"
    end
  end
end
