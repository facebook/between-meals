Gem::Specification.new do |s|
  s.name = 'between_meals'
  s.version = '0.0.8'
  s.homepage = 'https://github.com/facebook/between-meals'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'Between Meals'
  s.description = 'Library for calculation Chef differences between revisions'
  s.authors = ['Phil Dibowitz', 'Marcin Sawicki']
  s.files = %w{README.md LICENSE} + Dir.glob('lib/between_meals/*.rb') +
            Dir.glob('lib/between_meals/**/*.rb')
  s.license = 'Apache'
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
