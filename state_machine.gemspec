Gem::Specification.new do |s|
  s.name        = 'state_machine'
  s.version     = '0.0.1'
  s.required_ruby_version = '>= 2.3.0'
  s.date        = '2017-01-21'
  s.summary     = 'State Machine'
  s.description = 'A simple State Machine gem'
  s.authors     = ['Serhii Kutsko']
  s.email       = 'kutsko86@gmail.com'
  s.files       = %w(lib/state_machine.rb
                     lib/state_machine/event.rb
                     lib/state_machine/state.rb
                     lib/state_machine/errors.rb
                     lib/state_machine/version.rb)
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.license     = 'MIT'
  s.homepage    = 'https://bitbucket.org/sergey_kutsko/state_machine/overview'

  s.add_development_dependency('rake', '~> 0')
  s.add_development_dependency('simplecov', '~> 0')
  s.add_development_dependency('minitest', '~> 0')
  s.add_development_dependency('rubocop', '~> 0')
  s.add_runtime_dependency('ruby-graphviz', '~> 0')
  s.add_runtime_dependency('rake', '~> 0')
end
