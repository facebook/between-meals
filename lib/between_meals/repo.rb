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
    rescue
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
        require 'between_meals/repo/git'
        require 'between_meals/repo/hg'
        require 'between_meals/repo/svn'
        [
          BetweenMeals::Repo::Git,
          BetweenMeals::Repo::Hg,
          BetweenMeals::Repo::Svn,
        ].each do |klass|
          begin
            r = klass.new(repo_path, logger)
            if r.exists?
              logger.info("Repo found to be #{klass.to_s.split('::').last}")
              return r
            end
          rescue
            logger.debug("Skipping #{klass}")
          end
        end
        logger.warn("Failed detecting repo type at #{repo_path}")
        exit(1)
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
        raise "Do not know repo type #{type}"
      end
    end

    def bin=(bin)
      @bin = bin
      @cmd.bin = bin
    end

    def exists?
      raise "#{__method__} not implemented"
    end

    def status
      raise "#{__method__} not implemented"
    end

    # This method *must* succeed in the case of no repo directory so that
    # users can call `checkout`. Users may call `exists?` to find out if
    # we have an underlying repo yet.
    def setup
      raise "#{__method__} not implemented"
    end

    def head_rev
      raise "#{__method__} not implemented"
    end

    def head_msg
      raise "#{__method__} not implemented"
    end

    def head_msg=
      raise "#{__method__} not implemented"
    end

    def head_parents
      raise "#{__method__} not implemented"
    end

    def latest_revision
      raise "#{__method__} not implemented"
    end

    def create(_url)
      raise "#{__method__} not implemented"
    end

    # Return files changed between two revisions
    def changes(_start_ref, _end_ref)
      raise "#{__method__} not implemented"
    end

    def update
      raise "#{__method__} not implemented"
    end

    # Return all files
    def files
      raise "#{__method__} not implemented"
    end

    def head
      raise "#{__method__} not implemented"
    end

    def checkout
      raise "#{__method__} not implemented"
    end

    def last_author
      raise "#{__method__} not implemented"
    end

    def last_msg
      raise "#{__method__} not implemented"
    end

    def last_msg=
      raise "#{__method__} not implemented"
    end

    def name
      raise "#{__method__} not implemented"
    end

    def email
      raise "#{__method__} not implemented"
    end

    def upstream?(_rev)
      raise "#{__method__} not implemented"
    end

    def valid_ref?(_rev)
      raise "#{__method__} not implemented"
    end
  end
end
