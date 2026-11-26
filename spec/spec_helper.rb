require 'comicinfo/metron'

# Paths to the files in spec/fixtures
module FixtureHelpers
  def fixture_path filename
    path = File.join __dir__, 'fixtures', filename
    return path if File.exist? path

    raise "Fixture file not found: #{filename}"
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FixtureHelpers
end
