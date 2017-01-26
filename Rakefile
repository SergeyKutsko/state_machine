require 'rake/testtask'
require './test/movement_state'

namespace :state_machine do
  desc 'Draws state machines using GraphViz'
  task :draw do
    StateMachine.draw(MovementState)
  end
end


Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test