Gem::Specification.new do |s|
  s.name        = 'state_machine'
  s.version     = '0.0.1'
  s.date        = '2017-01-21'
  s.summary     = 'State Machine'
  s.description = 'A simple State Machine gem'
  s.authors     = ['Serhii Kutsko']
  s.email       = 'kutsko86@gmail.com'
  s.files       = %w[lib/state_machine.rb lib/state_machine/event.rb]
  s.license       = 'MIT'

  s.add_development_dependency("rake")
  s.add_development_dependency("simplecov")
  s.add_development_dependency("minitest")
end