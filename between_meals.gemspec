Gem::Specification.new do |s|
  s.name = 'between_meals'
  s.version = '0.0.5'
  s.homepage = 'https://github.com/facebook/between-meals'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'Between Meals'
  s.description = 'Library for calculation Chef differences between revisions'
  s.authors = ['Phil Dibowitz', 'Marcin Sawicki']
  s.files = %w{README.md LICENSE} + Dir.glob('lib/between_meals/*.rb') +
    Dir.glob('lib/between_meals/{changes,repo}/*.rb')
  s.license = 'Apache'
  %w{
    colorize
    json
    mixlib-shellout
    rugged
  }.each do |dep|
    s.add_dependency dep
  end
  %w{
    rspec-core
    rspec-expectations
    rspec-mocks
  }.each do |dep|
    s.add_development_dependency dep
  end
end
