Gem::Specification.new do |s|
  s.name = 'between-meals'
  s.version = '0.0.1'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'Between Meals'
  s.description = 'Library for calculation Chef differences between revisions'
  s.authors = ['Phil Dibowitz', 'Marcin Sawicki']
  s.files = %w{README.md LICENSE} + Dir.glob('lib/between-meals/*.rb') +
    Dir.glob('lib/between-meals/{changes,repo}/*.rb')
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
    s.add_development_dependency gem
  end
end
