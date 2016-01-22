require File.expand_path("../../environment_setup", __FILE__)

desc "Configure your environment for development"
task :setup do
  EnvironmentSetup.setup
end

desc "Check if your environment is setup for development"
task :check_setup do
  EnvironmentSetup.check_setup
end
