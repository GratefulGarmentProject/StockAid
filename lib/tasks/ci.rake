require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new
task spec: :rubocop
task default: :spec
