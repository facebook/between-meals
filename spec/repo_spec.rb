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

require 'between_meals/repo'
require 'between_meals/repo/git'
require 'between_meals/repo/svn'

describe 'BetweenMeals::Repo' do
  let(:class_interface) { BetweenMeals::Repo.public_methods.sort }
  let(:instance_interface) { BetweenMeals::Repo.instance_methods.sort }

  # Misc Repos should not expose anything more than parent class,
  # which default to 'Not implemented'
  [
    BetweenMeals::Repo::Git,
    BetweenMeals::Repo::Svn,
    BetweenMeals::Repo::Hg,
  ].each do |klass|
    it "#{klass} should conform to BetweenMeals::Repo class interface" do
      expect(klass.public_methods.sort).to eq(class_interface)
    end
    it "#{klass} should conform to BetweenMeals::Repo instance interface" do
      expect(klass.instance_methods.sort).to eq(instance_interface)
    end
  end
end
