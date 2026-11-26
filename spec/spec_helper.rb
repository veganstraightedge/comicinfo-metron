require 'comicinfo/metron'
require_relative 'support/metron_server'

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

  # A local Metron that answers with spec/fixtures, for the specs to look things up in
  fixtures_directory = File.join __dir__, 'fixtures'
  config.add_setting :metron_server, default: MetronServer.new(fixtures_directory:)
  config.before(:suite) { config.metron_server.start }
  config.after(:suite) { config.metron_server.stop }
end
