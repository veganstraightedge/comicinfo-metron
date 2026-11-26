require 'nokogiri'
require_relative 'cover_date'
require_relative 'credits'

module ComicInfo
  class Metron
    # A Metron issue as a ComicInfo::Issue.
    #
    # The issue is built from ComicInfo XML with only the fields Metron knows, so
    # ComicInfo::Issue#with_blanks_filled_from keeps what a comic already has.
    class FoundIssue
      # - issue: Metron's issue detail
      def initialize issue:
        @issue = issue
      end

      def to_issue
        ComicInfo.load(xml)
                 .with_characters(names(@issue[:characters]))
                 .with_genres(names(@issue.dig(:series, :genres)))
                 .with_teams(names(@issue[:teams]))
      end

      private

      # ComicInfo XML with every field Metron knows, by element name
      def xml
        document = Nokogiri::XML::Document.new
        root     = document.create_element 'ComicInfo'

        fields.each { |element, value| root.add_child document.create_element(element, value.to_s) }
        document.root = root

        document.to_xml
      end

      def fields
        credits    = Credits.new @issue[:credits].to_a
        cover_date = CoverDate.new @issue[:cover_date]

        {
          'Colorist'    => credits.names('colorist'),
          'CoverArtist' => credits.names('cover'),
          'Editor'      => credits.names('editor'),
          'Imprint'     => present(@issue.dig(:imprint, :name)),
          'Inker'       => credits.names('inker', 'artist'),
          'Letterer'    => credits.names('letterer'),
          'Month'       => cover_date.month,
          'Number'      => present(@issue[:number]),
          'Penciller'   => credits.names('penciller', 'artist'),
          'Publisher'   => present(@issue.dig(:publisher, :name)),
          'Series'      => present(@issue.dig(:series, :name)),
          'StoryArc'    => present(names(@issue[:arcs]).join(', ')),
          'Summary'     => present(@issue[:desc]),
          'Title'       => title,
          'Translator'  => credits.names('translator'),
          'Volume'      => volume,
          'Web'         => present(@issue[:resource_url]),
          'Writer'      => credits.names('writer', 'script', 'story', 'plot'),
          'Year'        => cover_date.year
        }.compact
      end

      # The collection's title, or else its first story's
      def title
        story_titles = @issue[:name].to_a.filter_map { present it }

        present(@issue[:title]) || story_titles.first
      end

      # The series' volume, or nil when Metron doesn't know it
      def volume
        volume = @issue.dig(:series, :volume)

        volume if volume.to_i.positive?
      end

      # The names of the characters, teams, genres, or story arcs Metron lists
      def names(items) = items.to_a.filter_map { it[:name] }

      # The text, trimmed, or nil when it's blank
      def present text
        trimmed = text.to_s.strip

        trimmed unless trimmed.empty?
      end
    end
  end
end
