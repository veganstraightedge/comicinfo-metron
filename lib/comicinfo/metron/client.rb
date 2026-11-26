require 'json'
require 'net/http'
require 'uri'
require_relative 'errors'

module ComicInfo
  class Metron
    # Calls the Metron API with one account's API token.
    #
    # Results are Metron's JSON, parsed with symbol keys. They follow Mokkari's schemas (Metron's
    # own Python client).
    class Client
      def initialize base_url:, token:, user_agent:
        @base_url   = base_url
        @token      = token
        @user_agent = user_agent
      end

      # The issues numbered number in series whose names contain series, narrowed to a cover year when there is one
      def find_issues number:, series:, cover_year: nil
        parameters = { cover_year:, number:, series_name: series }.compact

        get('issue/', parameters)[:results]
      end

      private

      # Calls one API resource and returns its parsed response
      def get path, parameters = {}
        uri       = URI.join @base_url, path
        uri.query = URI.encode_www_form parameters.sort unless parameters.empty?

        headers  = { 'Authorization' => "Bearer #{@token}", 'User-Agent' => @user_agent }
        response = Net::HTTP.get_response uri, headers
        raise HTTPError, response.code.to_i unless response.is_a? Net::HTTPOK

        JSON.parse response.body, symbolize_names: true
      end
    end
  end
end
