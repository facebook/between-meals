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
require 'between_meals/repo/hg'
require 'between_meals/repo.rb'
require 'logger'
require_relative 'repo_subclass_conformance'

describe BetweenMeals::Repo::Hg do
  context 'conforms to BetweenMeals::Repo interfaces' do
    it_behaves_like 'Repo subclass conformance', BetweenMeals::Repo::Git
  end
  let(:logger) do
    Logger.new('/dev/null')
  end

  examples = [
    {
      :name => 'empty filelists',
      :changes => '',
      :result => [],
    },
    {
      :name => 'handle additions',
      :changes => 'A bar/baz',
      :result => [
        { :status => :added, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle additions with spaces',
      :changes => 'A bar/baz bot',
      :result => [
        { :status => :added, :path => 'bar/baz bot' },
      ],
    },
    {
      :name => 'handle deletes',
      :changes => 'R bar/baz',
      :result => [
        { :status => :deleted, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle deletes with spaces',
      :changes => 'R bar/baz bot',
      :result => [
        { :status => :deleted, :path => 'bar/baz bot' },
      ],
    },
    {
      :name => 'handle modifications',
      :changes => 'M bar/baz',
      :result => [
        { :status => :modified, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle modifications with spaces',
      :changes => 'M bar/baz bot',
      :result => [
        { :status => :modified, :path => 'bar/baz bot' },
      ],
    },
    {
      :name => 'handle clean',
      :changes => 'C bar/baz',
      :result => [
        { :status => :clean, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle missing',
      :changes => '! bar/baz',
      :result => [
        { :status => :missing, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle untracked',
      :changes => '? bar/baz',
      :result => [
        { :status => :untracked, :path => 'bar/baz' },
      ],
    },
    {
      :name => 'handle ignored',
      :changes => 'I bar/baz',
      :result => [
        { :status => :ignored, :path => 'bar/baz' },
      ],
    },
  ]

  examples.each do |fixture|
    it "should handle #{fixture[:name]}" do
      allow_any_instance_of(BetweenMeals::Repo::Hg).
        to receive(:setup).and_return(true)
      hg = BetweenMeals::Repo::Hg.new('foo', logger)
      expect(hg.send(:parse_status, fixture[:changes])).
        to eq(fixture[:result])
    end
  end

  examples = [
    {
      :config => 'baz <foo@bar.com>',
      :name => 'baz',
      :email => 'foo@bar.com',
    },
    {
      :config => 'bar',
      :name => 'bar',
      :email => nil,
    },
    {
      :config => '',
      :name => nil,
      :email => nil,
    },
  ]

  examples.each do |example|
    it 'should read config' do
      cmd = double(Mixlib::ShellOut, :stdout => example[:config])
      allow_any_instance_of(BetweenMeals::Cmd).
        to receive(:cmd).and_return(cmd)

      hg = BetweenMeals::Repo::Hg.new('foo', logger)
      expect(hg.email).to eq(example[:email])
      expect(hg.name).to eq(example[:name])
    end
  end

  it 'should handle malformed output' do
    allow_any_instance_of(BetweenMeals::Repo::Hg).
      to receive(:setup).and_return(true)
    hg = BetweenMeals::Repo::Hg.new('foo', logger)
    expect(lambda do
      hg.send(:parse_status, 'HGFS djs/ dsd)')
    end).to raise_error('Failed to parse repo diff line.')
  end
end
