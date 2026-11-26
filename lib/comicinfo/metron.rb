require 'comicinfo'
require_relative 'metron/version'

module ComicInfo
  # Looks up comic details in Metron, https://metron.cloud
  #
  #   metron  = ComicInfo::Metron.new token: token, user_agent: 'MyApp/1.0'
  #   matches = metron.matches issue
  #   found   = metron.issue matches.first
  #   updated = issue.with_blanks_filled_from found
  #
  # Whatever shows Metron's data credits and links back to it. Requests are made with a Metron
  # account's API token.
  class Metron
    BASE_URL = 'https://metron.cloud/api/'.freeze

    # - token: the account's Metron API token
    # - user_agent: names the app, such as "MyApp/1.0"
    # - base_url: where the API is, for testing against a server of your own
    def initialize token:, user_agent:, base_url: BASE_URL
      @base_url   = base_url
      @token      = token
      @user_agent = user_agent
    end

    def name     = 'Metron'
    def home_url = 'https://metron.cloud/'

    # What the issue still needs before it can be searched for, or nil
    def missing_details issue
      return if present(issue.series) && present(issue.number)

      'Metron needs a Series and a Number to search for.'
    end

    private

    # The text, trimmed, or nil when it's blank
    def present text
      trimmed = text.to_s.strip

      trimmed unless trimmed.empty?
    end
  end
end
