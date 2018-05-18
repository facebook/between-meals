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

require 'between_meals/cmd'
require 'tempfile'

module BetweenMeals
  class Repo
    class Hg < BetweenMeals::Repo
      class Cmd < BetweenMeals::Cmd
        def rev(rev)
          cmd("log -r #{rev}")
        end

        def log(template, rev = '.')
          cmd("log -r #{rev} -l 1 -T '{#{template}}'")
        end

        def clone(url, repo_path)
          cmd("clone #{url} #{repo_path}")
        end

        def pull
          cmd('pull --rebase')
        end

        def manifest
          cmd('manifest')
        end

        def username
          cmd('config ui.username')
        end

        def amend(msg)
          f = Tempfile.new('between_meals.hg.amend')
          begin
            f.write(msg)
            f.flush
            cmd("commit --amend --exclude '**' -l #{f.path}")
          ensure
            f.close
            f.unlink
          end
        end

        def status(start_ref = nil, end_ref = nil)
          if start_ref && end_ref
            cmd("status --rev #{start_ref} --rev #{end_ref}")
          elsif start_ref
            cmd("status --rev #{start_ref}")
          else
            cmd('status')
          end
        end
      end
    end
  end
end
