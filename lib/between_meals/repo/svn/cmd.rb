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
    class Svn < ::BetweenMeals::Repo
      class Cmd < ::BetweenMeals::Cmd
        def diff(start_ref, end_ref, repo_path)
          cmd("diff -r #{start_ref}:#{end_ref} --summarize #{repo_path}")
        end

        def info(repo_path)
          cmd("info #{repo_path}")
        end

        def info_r(ref, repo_path)
          cmd("info -r #{ref} #{repo_path}")
        end

        def co(url, repo_path)
          cmd("co --ignore-externals #{url} #{repo_path}")
        end

        def revert(repo_path)
          cmd("revert -R #{repo_path}")
        end

        def update(repo_path)
          cmd("update #{repo_path}")
        end

        def cleanup(repo_path)
          cmd("cleanup #{repo_path}")
        end

        def ls(repo_path)
          cmd("ls --depth infinity #{repo_path}")
        end
      end
    end
  end
end
