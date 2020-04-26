APP_ROOT = File.expand_path("../../app", __FILE__)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "tmp/spec_examples.txt"
  config.disable_monkey_patching!
  config.expose_dsl_globally = true
  config.profile_examples = 2
  config.order = :random
  Kernel.srand config.seed
end
