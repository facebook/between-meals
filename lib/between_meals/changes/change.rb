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

# rubocop:disable ClassVars
module BetweenMeals
  # A set of classes that represent a given item's change (a cookbook
  # that's changed, a role that's changed or a databag item that's changed).
  #
  # You almost certainly don't want to use this directly, and instead want
  # BetweenMeals::Changeset
  module Changes
    # Common functionality
    class Change
      # Since we either need to upload or delete, we only accept two statuses.
      # VCSs will differentiate between various kinds of modifies, adds, etc.
      # so instead of handling all possibilities here, we expect the caller to
      # collapse them into `:modified` or `:deleted`.
      ALLOWED_STATUSES = [:modified, :deleted].freeze #: Array[Symbol]
      @@logger = nil
      attr_accessor :name
      attr_reader :status

      #: () -> String
      def to_s
        @name
      end

      def status=(value)
        unless ALLOWED_STATUSES.include?(value)
          fail "#{self.class} status attribute can only be one of #{ALLOWED_STATUSES} not #{value}"
        end
        @status = value
      end

      # People who use us through find() can just pass in logger,
      # for everyone else, here's a setter
      def logger=(log)
        @@logger = log
      end

      def self.info(msg)
        @@logger&.info(msg)
      end

      def self.debug(msg)
        @@logger&.debug(msg)
      end

      def info(msg)
        BetweenMeals::Changes::Change.info(msg)
      end

      def debug(msg)
        BetweenMeals::Changes::Change.debug(msg)
      end
    end
  end
end
# rubocop:enable ClassVars
