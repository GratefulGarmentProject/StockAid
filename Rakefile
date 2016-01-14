require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new

desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w(--color)
end

task spec: :rubocop
task default: :spec
