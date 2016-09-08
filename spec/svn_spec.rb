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
require 'between_meals/repo/svn'
require 'between_meals/repo.rb'
require 'logger'

describe BetweenMeals::Repo::Svn do
  let(:logger) do
    Logger.new('/dev/null')
  end

  fixtures = [
    {
      :name => 'handle additions',
      :changes => 'A foo/bar/baz',
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle file modifications',
      :changes => 'M foo/bar/baz',
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle file modifications',
      :changes => 'M          foo/bar/baz',
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle attribute modifications',
      :changes => ' M foo/bar/baz',
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle file & attribute modifications',
      :changes => 'MM foo/bar/baz',
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle deletes',
      :changes => 'D foo/bar/baz',
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
      ],
    },
  ]

  fixtures.each do |fixture|
    it "should handle #{fixture[:name]}" do
      BetweenMeals::Repo::Svn.any_instance.stub(:setup).and_return(true)
      svn = BetweenMeals::Repo::Svn.new('foo', logger)
      svn.send(:parse_status, fixture[:changes]).
        should eq(fixture[:result])
    end
  end
  it 'should error on spaces in file names' do
    BetweenMeals::Repo::Svn.any_instance.stub(:setup).and_return(true)
    svn = BetweenMeals::Repo::Svn.new('foo', logger)
    lambda do
      svn.send(:parse_status, 'M foo/bar baz')
    end.should raise_error('Failed to parse repo status line. Try a --force-upload.')
  end
  it 'should handle malformed output' do
    BetweenMeals::Repo::Svn.any_instance.stub(:setup).and_return(true)
    svn = BetweenMeals::Repo::Svn.new('foo', logger)
    lambda do
      svn.send(:parse_status, 'HGFS djs/ dsd)')
    end.should raise_error('No match')
  end
end
