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

# Test if rugged gem is available, skip tests if not
begin
  require 'rugged'
rescue LoadError
  return
end

require 'between_meals/repo/git'
require 'between_meals/repo.rb'
require 'logger'
require_relative 'repo_subclass_conformance'

describe BetweenMeals::Repo::Git do
  context 'conforms to BetweenMeals::Repo interfaces' do
    it_behaves_like 'Repo subclass conformance', BetweenMeals::Repo::Git
  end
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
      :name => 'renames',
      :changes => "R050\tfoo/bar/baz\tfoo/bang/bong",
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
        { :status => :modified, :path => 'bang/bong' },
      ],
    },
    {
      :name => 'renames with spaces',
      :changes => "R050\tfoo/bar/baz bad\tfoo/bang/baz_good",
      :result => [
        { :status => :deleted, :path => 'bar/baz bad' },
        { :status => :modified, :path => 'bang/baz_good' },
      ],
    },
    {
      :name => 'type changes',
      :changes => "T\tfoo/bar/baz",
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'additions',
      :changes => "A\tfoo/bar/baz",
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'additions with spaces',
      :changes => "A\tfoo/bar/baz derp",
      :result => [
        { :status => :modified, :path => 'bar/baz derp' },
      ],
    },
    {
      :name => 'deletes',
      :changes => "D\tfoo/bar/baz",
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'modifications',
      :changes => "M004\tfoo/bar/baz",
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle misc',
      :changes => <<CHANGES,
R050\tfoo/bar/baz\tfoo/bang/bong
D\tfoo/bar/baz
C\tfoo/bar/baz\tfoo/bang/bong
D\tfoo/bar/baz bad
CHANGES
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
        { :status => :modified, :path => 'bang/bong' },
        { :status => :deleted, :path => 'bar/baz' },
        { :status => :modified, :path => 'bang/bong' },
        { :status => :deleted, :path => 'bar/baz bad' },
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

  it 'should handle malformed output' do
    expect_any_instance_of(BetweenMeals::Repo::Git).
      to receive(:setup).and_return(true)
    git = BetweenMeals::Repo::Git.new('foo', logger)
    expect(lambda do
      git.send(:parse_status, 'HGFS djs/ dsd)')
    end).to raise_error('Failed to parse repo diff line.')
  end
end
