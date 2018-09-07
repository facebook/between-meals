# frozen_string_literal: true

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
      :result => [],
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
      :changes => <<CHANGES ,
R050 foo/bar/baz foo/bang/bong
D foo/bar/baz
C foo/bar/baz foo/bang/bong
CHANGES
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
      expect_any_instance_of(BetweenMeals::Repo::Git).
        to receive(:setup).and_return(true)
      git = BetweenMeals::Repo::Git.new('foo', logger)
      expect(git.send(:parse_status, fixture[:changes])).
        to eq(fixture[:result])
    end
  end

  it 'should error on spaces in file names' do
    expect_any_instance_of(BetweenMeals::Repo::Git).
      to receive(:setup).and_return(true)
    git = BetweenMeals::Repo::Git.new('foo', logger)
    expect(lambda do
      git.send(:parse_status, 'M foo/bar baz')
    end).to raise_error('Failed to parse repo diff line.')
  end

  it 'should handle malformed output' do
    expect_any_instance_of(BetweenMeals::Repo::Git).
      to receive(:setup).and_return(true)
    git = BetweenMeals::Repo::Git.new('foo', logger)
    expect(lambda do
      git.send(:parse_status, 'HGFS djs/ dsd)')
    end).to raise_error('Failed to parse repo diff line.')
  end
end
