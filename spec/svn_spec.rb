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
require_relative 'repo_subclass_conformance'

describe BetweenMeals::Repo::Svn do
  context 'conforms to BetweenMeals::Repo interfaces' do
    it_behaves_like 'Repo subclass conformance', BetweenMeals::Repo::Svn
  end
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
      :name => 'handle additions with files with spaces',
      :changes => 'A foo/bar/baz bot',
      :result => [
        { :status => :modified, :path => 'bar/baz bot' },
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
      :name => 'handle attribute modifications on files with spaces',
      :changes => ' M foo/bar/baz bot',
      :result => [
        { :status => :modified, :path => 'bar/baz bot' },
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
      :name => 'handle file & attribute modifications on files with spaces',
      :changes => 'MM foo/bar/baz bot',
      :result => [
        { :status => :modified, :path => 'bar/baz bot' },
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
      :name => 'handle deletes for files with spaces',
      :changes => 'D foo/bar/baz bot',
      :result => [
        { :status => :deleted, :path => 'bar/baz bot' },
      ],
    },
  ]

  fixtures.each do |fixture|
    it "should handle #{fixture[:name]}" do
      expect_any_instance_of(BetweenMeals::Repo::Svn).
        to receive(:setup).and_return(true)
      svn = BetweenMeals::Repo::Svn.new('foo', logger)
      expect(svn.send(:parse_status, fixture[:changes])).
        to eq(fixture[:result])
    end
  end

  it 'should handle malformed output' do
    expect_any_instance_of(BetweenMeals::Repo::Svn).
      to receive(:setup).and_return(true)
    svn = BetweenMeals::Repo::Svn.new('foo', logger)
    expect(lambda do
      svn.send(:parse_status, 'HGFS djs/ dsd)')
    end).to raise_error('Failed to parse repo diff line.')
  end
end
