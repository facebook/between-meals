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
require 'between_meals/changes/databag'
require 'logger'

describe BetweenMeals::Changes::Databag do
  let(:logger) do
    Logger.new('/dev/null')
  end
  let(:roles_dir) do
    'databags'
  end

  fixtures = [
    {
      :name => 'empty filelists',
      :files => [],
      :result => [],
    },
    {
      :name => 'delete databag',
      :files => [
        {
          :status => :deleted,
          :path => 'databags/test/databag1.json',
        },
        {
          :status => :deleted,
          :path => 'databags/test1/test2/databag2.json',
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
      :name => 'add/modify a databag',
      :files => [
        {
          :status => :modified,
          :path => 'databags/one/databag1.json',
        },
        {
          :status => :deleted,
          :path => 'databags/test/databag2.rb', # wrong extension
        },
        {
          :status => :deleted,
          :path => 'databags/two/databag3.json',
        },
        {
          :status => :added,
          :path => 'databags/three/databag1.json',
        },
      ],
      :result => [
        ['one', :modified], ['two', :deleted], ['three', :modified]
      ],
    },
  ]

  fixtures.each do |fixture|
    it "should handle #{fixture[:name]}" do
      expect(BetweenMeals::Changes::Databag.find(
        fixture[:files],
        roles_dir,
        logger,
      ).map do |cb|
        [cb.name, cb.status]
      end).to eq(fixture[:result])
    end
  end
end
