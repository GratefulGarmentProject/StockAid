unless Rails.env.production?
  require "rubocop/rake_task"
  require "rspec/core/rake_task"

  RuboCop::RakeTask.new
  task spec: [:check_setup, :rubocop]
  task default: :spec
end
