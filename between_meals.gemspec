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
  s.version = '0.0.12'
  s.summary = 'Between Meals'
  s.description = 'Library for calculating Chef differences between revisions'
  s.license = 'Apache-2.0'
  s.authors = ['Phil Dibowitz', 'Marcin Sawicki']
  s.homepage = 'https://github.com/facebook/between-meals'
  s.platform = Gem::Platform::RUBY

  s.extra_rdoc_files = %w{README.md LICENSE}

  s.files = %w{README.md LICENSE} +
    Dir.glob('lib/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) }

  s.required_ruby_version = '>= 2.7.0'
  s.add_dependency 'colorize'
  s.add_dependency 'mixlib-shellout'
end
