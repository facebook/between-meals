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

require 'between_meals/cmd'

module BetweenMeals
  class Repo
    class Git < ::BetweenMeals::Repo
      class Cmd < ::BetweenMeals::Cmd
        def config(key)
          s = cmd("config #{key}", nil, true)
          unless [0, 1].include?(s.exitstatus)
            s.error!
          end
          s
        end

        def clone(url, repo_path)
          cmd("clone #{url} #{repo_path}", '/tmp')
        end

        def diff(start_ref, end_ref)
          cmd("diff --name-status #{start_ref} #{end_ref}")
        end

        def pull
          cmd('pull --rebase')
        end

        def merge_base(rev, master)
          cmd("merge-base #{rev} #{master}")
        end

        def status
          cmd('status --porcelain 2>&1')
        end
      end
    end
  end
end
