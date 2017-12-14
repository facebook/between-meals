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
    # Changeset aware databag
    class Databag < Change
      attr_accessor :item
      def self.name_from_path(path, databag_dir)
        re = %r{^#{databag_dir}/([^/]+)/([^/]+)\.json}
        debug("[databag] Matching #{path} against #{re}")
        m = path.match(re)
        if m
          info("Databag is #{m[1]} item is #{m[2]}")
          return m[1], m[2]
        end
        nil
      end

      def initialize(file, databag_dir)
        @status = file[:status]
        @name, @item = self.class.name_from_path(file[:path], databag_dir)
      end

      def self.find(list, databag_dir, logger)
        # rubocop:disable ClassVars
        @@logger = logger
        # rubocop:enable ClassVars
        return [] if list.nil? || list.empty?
        list.
          select { |x| self.name_from_path(x[:path], databag_dir) }.
          map do |x|
            BetweenMeals::Changes::Databag.new(x, databag_dir)
          end
      end
    end
  end
end
