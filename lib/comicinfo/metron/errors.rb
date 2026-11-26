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

    # A match's ID isn't a Metron issue ID, so it can't have come from Metron
    class InvalidIssueIDError < Error
      attr_reader :id

      def initialize id
        @id = id
        super("“#{id}” isn't a Metron issue ID.")
      end
    end
  end
end
