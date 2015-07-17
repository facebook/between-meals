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
      @@logger = nil
      attr_accessor :name, :status
      def to_s
        @name
      end

      # People who use us through find() can just pass in logger,
      # for everyone else, here's a setter
      def logger=(log)
        @@logger = log
      end

      def self.info(msg)
        if @@logger
          @@logger.info(msg)
        end
      end

      def self.debug(msg)
        if @@logger
          @@logger.debug(msg)
        end
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
