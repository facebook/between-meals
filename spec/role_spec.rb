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

require 'spec_helper'
require 'between_meals/changes/change'
require 'between_meals/changes/role'
require 'logger'

describe BetweenMeals::Changes::Role do
  let(:logger) do
    Logger.new('/dev/null')
  end
  let(:roles_dir) do
    'roles'
  end

  fixtures = [
    {
      :name => 'empty filelists',
      :files => [],
      :result => [],
    },
    {
      :name => 'delete role',
      :files => [
        {
          :status => :deleted,
          :path => 'roles/test.rb',
        },
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/metadata.rb',
        },
      ],
      :result => [
        ['test', :deleted],
      ],
    },
    {
      :name => 'delete JSON role',
      :files => [
        {
          :status => :deleted,
          :path => 'roles/test.json',
        },
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/metadata.rb',
        },
      ],
      :result => [
        ['test', :deleted],
      ],
    },
    {
      :name => 'add/modify a role',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/one/cb_one/recipes/test.rb',
        },
        {
          :status => :modified,
          :path => 'roles/test.rb',
        },
        {
          :status => :modified,
          :path => 'cookbooks/one/cb_one/recipes/test3.rb',
        },
      ],
      :result => [
        ['test', :modified],
      ],
    },
    {
      :name => 'add/modify a JSON role',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/one/cb_one/recipes/test.rb',
        },
        {
          :status => :modified,
          :path => 'roles/test.json',
        },
        {
          :status => :modified,
          :path => 'cookbooks/one/cb_one/recipes/test3.rb',
        },
      ],
      :result => [
        ['test', :modified],
      ],
    },
  ]

  fixtures.each do |fixture|
    it "should handle #{fixture[:name]}" do
      BetweenMeals::Changes::Role.find(
        fixture[:files],
        roles_dir,
        logger,
      ).map do |cb|
        [cb.name, cb.status]
      end.
        should eq(fixture[:result])
    end
  end
end
