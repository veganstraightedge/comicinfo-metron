module ComicInfo
  class Metron
    # Why a Metron request failed
    class Error < ComicInfo::Error; end

    # Metron answered with an HTTP error status, such as 401 for a wrong token, or 429
    class HTTPError < Error
      attr_reader :status

      def initialize status
        @status = status
        super("Metron answered with HTTP status #{status}.")
      end
    end
  end
end
