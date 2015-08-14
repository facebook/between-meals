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
require 'between_meals/repo/git'
require 'between_meals/repo.rb'
require 'logger'

describe BetweenMeals::Repo::Git do
  let(:logger) do
    Logger.new('/dev/null')
  end

  fixtures = [
    {
      :name => 'empty filelists',
      :changes => '',
      :result => []
    },
    {
      :name => 'handle renames',
      :changes => 'R050 foo/bar/baz foo/bang/bong',
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
        { :status => :modified, :path => 'bang/bong' },
      ],
    },
    {
      :name => 'handle type changes',
      :changes => 'T foo/bar/baz',
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle additions',
      :changes => 'A foo/bar/baz',
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
    {
      :name => 'handle modifications',
      :changes => 'M004 foo/bar/baz',
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle misc',
      :changes => <<EOS ,
R050 foo/bar/baz foo/bang/bong
D foo/bar/baz
C foo/bar/baz foo/bang/bong
EOS
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
        { :status => :modified, :path => 'bang/bong' },
        { :status => :deleted, :path => 'bar/baz' },
        { :status => :modified, :path => 'bang/bong' },
      ],
    },
  ]

  fixtures.each do |fixture|
    it "should handle #{fixture[:name]}" do
      BetweenMeals::Repo::Git.any_instance.stub(:setup).and_return(true)
      git = BetweenMeals::Repo::Git.new('foo', logger)
      git.send(:parse_status, fixture[:changes]).
        should eq(fixture[:result])
    end
  end
  it 'should handle malformed output' do
    BetweenMeals::Repo::Git.any_instance.stub(:setup).and_return(true)
    git = BetweenMeals::Repo::Git.new('foo', logger)
    lambda do
      git.send(:parse_status, 'HGFS djs/ dsd)')
    end.should raise_error('No match')
  end
end
