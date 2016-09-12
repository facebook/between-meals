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
require 'between_meals/changes/cookbook'
require 'between_meals/changeset'
require 'logger'

describe BetweenMeals::Changes::Cookbook do
  let(:logger) do
    Logger.new('/dev/null')
  end
  let(:cookbook_dirs) do
    ['cookbooks/one', 'cookbooks/two']
  end

  fixtures = [
    {
      :name => 'empty filelists',
      :files => [],
      :result => [],
    },
    {
      :name => 'modifying of a cookbook',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/recipes/test.rb',
        },
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/metadata.rb',
        },
      ],
      :result => [
        ['cb_one', :modified],
      ],
    },
    {
      :name => 'a mix of in-place modifications and deletes',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/one/cb_one/recipes/test.rb',
        },
        {
          :status => :deleted,
          :path => 'cookbooks/one/cb_one/recipes/test2.rb',
        },
        {
          :status => :modified,
          :path => 'cookbooks/one/cb_one/recipes/test3.rb',
        },
      ],
      :result => [
        ['cb_one', :modified],
      ],
    },
    {
      :name => 'removing metadata.rb - invalid cookbook, delete it',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/one/cb_one/recipes/test.rb',
        },
        {
          :status => :deleted,
          :path => 'cookbooks/one/cb_one/metadata.rb',
        },
      ],
      :result => [
        ['cb_one', :deleted],
      ],
    },
    {
      :name => 'changing cookbook location',
      :files => [
        {
          :status => :deleted,
          :path => 'cookbooks/one/cb_one/recipes/test.rb',
        },
        {
          :status => :deleted,
          :path => 'cookbooks/one/cb_one/metadata.rb',
        },
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/recipes/test.rb',
        },
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/recipes/test2.rb',
        },
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/metadata.rb',
        },
      ],
      :result => [
        ['cb_one', :deleted],
        ['cb_one', :modified],
      ],
    },
    {
      :name => 'modifying metadata only',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/metadata.rb',
        },
      ],
      :result => [
        ['cb_one', :modified],
      ],
    },
    {
      :name => 'modifying README only',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/README.md',
        },
      ],
      :result => [
        ['cb_one', :modified],
      ],
    },
    {
      :name => 'modifying recipe only',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/two/cb_one/recipe/default.rb',
        },
      ],
      :result => [
        ['cb_one', :modified],
      ],
    },
    {
      :name => 'skipping non-cookbook files',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/two/OWNERS',
        },
        {
          :status => :modified,
          :path => 'cookbooks/OWNERS',
        },
        {
          :status => :modified,
          :path => 'OWNERS',
        },
      ],
      :result => [
      ],
    },
  ]

  fixtures.each do |fixture|
    it "should handle #{fixture[:name]}" do
      BetweenMeals::Changes::Cookbook.find(
        fixture[:files],
        cookbook_dirs,
        logger,
      ).map do |cb|
        [cb.name, cb.status]
      end.
        should eq(fixture[:result])
    end
  end
end
