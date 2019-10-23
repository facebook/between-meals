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

module BetweenMeals
  module Changes
    # Changeset aware role
    class Role < Change
      def self.name_from_path(path, role_dir)
        re = %r{^#{role_dir}/(.+)\.(?:rb|json)}
        debug("[role] Matching #{path} against #{re}")
        m = path.match(re)
        if m
          info("Name is #{m[1]}")
          return m[1]
        end
        nil
      end

      def initialize(file, role_dir)
        @status = file[:status] == :deleted ? :deleted : :modified
        @name = self.class.name_from_path(file[:path], role_dir)
      end

      # Given a list of changed files
      # create a list of Role objects
      def self.find(list, role_dir, logger)
        # rubocop:disable Style/ClassVars
        @@logger = logger
        # rubocop:enable Style/ClassVars
        return [] if list.nil? || list.empty?

        list.
          select { |x| self.name_from_path(x[:path], role_dir) }.
          map do |x|
            BetweenMeals::Changes::Role.new(x, role_dir)
          end
      end
    end
  end
end
