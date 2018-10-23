require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'i_am_i_can'
require 'database_cleaner'
require 'pp'
require 'pry'

require 'support/database'
require 'app/config/user_am_user_can'
require 'app/models/user_role'
require 'app/models/user_role_group'
require 'app/models/user_permission'
require 'app/models/resource'
require 'app/models/user'

ENV['ITEST'] = "true"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

RSpec::Matchers.define :contain do |expected|
  match do |actual|
    (expected - actual).empty?
  end

  failure_message { |actual| " expected: #{actual}\ncontain: #{expected}" }
  # description { "#{expected}" }
end

RSpec::Matchers.define :have_size do |expected|
  match do |actual|
    actual.size == expected
  end

  failure_message { |actual| " expected: #{actual} (size: #{actual.size})\nhave size: #{expected}" }
  description { "have #{expected} items" }
end

class Hash
  alias names keys
end
