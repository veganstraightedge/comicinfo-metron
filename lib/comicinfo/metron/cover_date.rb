module ComicInfo
  class Metron
    # A cover date such as "2012-03-01", as a year and month.
    #
    # The day is left out: a cover date carries the 1st when only the month is known.
    class CoverDate
      def initialize text
        @parts = text.to_s.split '-'
      end

      # The year, or nil when there isn't one
      def year
        year = Integer @parts[0], 10, exception: false if @parts.length >= 2

        year if year&.between? 1000, 9999
      end

      # The month, 1 to 12, or nil when there isn't one
      def month
        month = Integer @parts[1], 10, exception: false if @parts.length >= 2

        month if month&.between? 1, 12
      end
    end
  end
end
