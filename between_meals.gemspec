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

Gem::Specification.new do |s|
  s.name = 'between_meals'
  s.version = '0.0.11'
  s.homepage = 'https://github.com/facebook/between-meals'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'Between Meals'
  s.description = 'Library for calculation Chef differences between revisions'
  s.authors = ['Phil Dibowitz', 'Marcin Sawicki']
  s.files = %w{README.md LICENSE} + Dir.glob('lib/between_meals/*.rb') +
            Dir.glob('lib/between_meals/**/*.rb')
  s.license = 'Apache-2.0'
  %w{
    colorize
    mixlib-shellout
    rugged
  }.each do |dep|
    s.add_dependency dep
  end
  %w{
    rspec-core
    rspec-expectations
    rspec-mocks
    simplecov
  }.each do |dep|
    s.add_development_dependency dep
  end
  s.add_development_dependency 'rubocop', '0.49.1'
end
