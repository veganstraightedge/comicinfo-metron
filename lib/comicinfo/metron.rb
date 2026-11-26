require 'comicinfo'
require_relative 'metron/client'
require_relative 'metron/errors'
require_relative 'metron/found_issue'
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
      @client = Client.new(base_url:, token:, user_agent:)
    end

    def name     = 'Metron'
    def home_url = 'https://metron.cloud/'

    # What the issue still needs before it can be searched for, or nil
    def missing_details issue
      return if present(issue.series) && present(issue.number)

      'Metron needs a Series and a Number to search for.'
    end

    # The issues with the issue's number in every series whose name contains its series, best first.
    #
    # When the issue has a year, only issues with a cover dated that year are asked for.
    def matches issue
      cover_year = issue.year if issue.year.to_i.positive?
      found      = client.find_issues cover_year:, number: present(issue.number), series: present(issue.series)
      matches    = found.map { match_for it }

      issue.rank matches
    end

    # Everything Metron knows about the match's issue, as a ComicInfo::Issue
    def issue match
      id = Integer match.id, 10, exception: false
      raise InvalidIssueIDError, match.id unless id

      found = client.issue id

      FoundIssue.new(issue: found).to_issue
    end

    private

    attr_reader :client

    # One issue from the issue list as a match.
    #
    # Metron's issue pages are addressed by a slug, which the list doesn't have, so it has no site URL.
    def match_for found
      series     = found.dig(:series, :name) || ''
      heading    = present(found[:issue]) || "#{series} ##{found[:number]}"
      cover_date = "Cover date #{present(found[:cover_date]) || 'unknown'}"

      Match.new cover_date: found[:cover_date],
                details:    cover_date,
                heading:,
                id:         found[:id].to_s,
                number:     found[:number],
                series:
    end

    # The text, trimmed, or nil when it's blank
    def present text
      trimmed = text.to_s.strip

      trimmed unless trimmed.empty?
    end
  end
end
