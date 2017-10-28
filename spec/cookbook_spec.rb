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
require 'find'

describe BetweenMeals::Changes::Cookbook do
  let(:logger) do
    Logger.new('/dev/null')
  end
  let(:cookbook_dirs) do
    ['cookbooks/one', 'cookbooks/two', 'cookbooks/three']
  end
  let(:repo_path) do
    "#{ENV['HOME']}/devfiles"
  end

  class Repo
    def repo_path
      "#{ENV['HOME']}/devfiles"
    end
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
      :name => 'modifying of a cookbook file',
      :files => [
        {
          :status => :modified,
          :path => 'cookbooks/one/cb_one/files/chefctl.rb',
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
    {
      :name => 'when metadata file is not in the root of the cb dir',
      :files => [
        {
          :status => :deleted,
          :path => 'cookbooks/two/cb_one/files/default/metadata.rb',
        },
      ],
      :result => [
        ['cb_one', :modified],
      ],
    },
  ]

  {
    'Normally' => false,
    'With symlinks' => true,
  }.each do |c, track_symlinks|
    context "Running BetweenMeals #{c}" do
      before do
        allow(File).to receive(:realpath).with(repo_path).and_return(repo_path)
        if track_symlinks
          cookbook_dirs.each do |dir|
            # This mocks out that there is a cookbook and script symlinked
            # from a different cookbook_dir, For all of the tests.
            repo = File.join(repo_path, dir)
            link1 = "#{repo_path}/cookbooks/three/cb_one"
            link2 = "#{repo_path}/cookbooks/three/cb_one/files/chefctl.rb"
            links = [link1, link2]
            src1 = 'cookbooks/one/cb_one'
            src2 = 'cookbooks/one/cb_one/files/chefctl.rb'
            find_res = dir.include?('three') ? links : []
            allow(Find).to receive(:find).with(repo).and_return(find_res)
            allow(File).to receive(:symlink?).and_return(true)
            allow(File).to receive(:absolute_path).with(link1).and_return(src1)
            allow(File).to receive(:absolute_path).with(link2).and_return(src2)
          end
        end
      end
      fixtures.each do |fixture|
        it "should handle #{fixture[:name]}" do
          # If we are track_symlinks and there were changes to one/cb_one or to
          # the chefctl script in one/cb_one, we should expect one more upload
          # of cb_one, to the cookbooks/three locaiton.
          files = fixture[:files]
          res = fixture[:result]
          ctl = files.select { |f| f[:path].include?('chefctl') }.any?
          cb_one = files.select { |f| f[:path].include?('one/cb_one') }.any?
          if track_symlinks && (ctl || cb_one)
            cb_one_res = res.find { |r| r[1] if r[0].include?('cb_one') }
            fixture[:result] << cb_one_res
          end
          expect(BetweenMeals::Changes::Cookbook.find(
            fixture[:files],
            cookbook_dirs,
            logger,
            Repo.new,
            track_symlinks,
          ).map do |cb|
            [cb.name, cb.status]
          end).to eq(fixture[:result])
        end
      end
    end
  end
end
