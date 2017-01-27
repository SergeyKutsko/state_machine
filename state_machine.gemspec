Gem::Specification.new do |s|
  s.name        = 'state_machine'
  s.version     = '0.0.1'
  s.date        = '2017-01-21'
  s.summary     = 'State Machine'
  s.description = 'A simple State Machine gem'
  s.authors     = ['Serhii Kutsko']
  s.email       = 'kutsko86@gmail.com'
  s.files       = %w[lib/state_machine.rb lib/state_machine/event.rb lib/state_machine/state.rb]
  s.license     = 'MIT'
  s.homepage    = 'https://bitbucket.org/sergey_kutsko/state_machine/overview'

  s.add_development_dependency('rake')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('minitest')
  s.add_development_dependency('rubocop')
  s.add_runtime_dependency('ruby-graphviz')
end