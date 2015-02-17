Gem::Specification.new do |s|
  s.name        = 'telly'
  s.version     = '0.1.2'
  s.date        = '2015-02-13'
  s.summary     = "Imports beaker results into TestRail test run results"
  s.description = "Imports beaker results into TestRail test run results"
  s.authors     = ["Joe Pinsonault", "Puppetlabs"]
  s.email       = 'joe.pinsonault@gmail.com'

  s.files       = Dir["lib/**/*"]
  s.executables = ['telly']
  s.homepage    = 'http://rubygems.org/gems/telly'
  s.license     = 'Apache'

  s.add_runtime_dependency 'webmock'
  s.add_runtime_dependency 'nokogiri'
  s.add_development_dependency 'rspec'
end
