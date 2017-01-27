Gem::Specification.new do |s|
  s.name        = 'state_machine'
  s.version     = StateMachine::Version
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

  s.add_development_dependency('rake')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('minitest')
  s.add_development_dependency('rubocop')
  s.add_runtime_dependency('ruby-graphviz')
  s.add_runtime_dependency('rake')
end
