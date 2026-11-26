module ComicInfo
  class Metron
    # The creators credited on an issue, and their roles.
    #
    # Metron gives each creator a list of roles, such as Artist and Cover.
    class Credits
      def initialize credits
        @credits = credits
      end

      # Everyone credited with any of the roles (lowercase), each once, in credit order, joined with commas;
      # nil when no one is
      def names *roles
        people = @credits.select { credited_with? it, roles }.map { it[:creator] }.uniq

        people.join ', ' unless people.empty?
      end

      private

      def credited_with? credit, roles
        credit_roles = credit[:role].to_a.map { it[:name].to_s.downcase }

        credit_roles.intersect? roles
      end
    end
  end
end
