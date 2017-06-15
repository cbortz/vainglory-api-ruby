require 'ostruct'

module VaingloryAPI
  # Helper class for metadata pertaining to regions
  #
  # @see https://developer.vainglorygame.com/docs#regions Vainglory API "Regions"
  class Region
    DB = [
      ['general', 'na', 'North America'],
      ['general', 'eu', 'Europe'],
      ['general', 'sa', 'South America'],
      ['general', 'ea', 'East Asia'],
      ['general', 'sg', 'Southeast Asia (SEA)'],
      ['tournament', 'tournament-na', 'North America Tournaments'],
      ['tournament', 'tournament-eu', 'Europe Tournaments'],
      ['tournament', 'tournament-sa', 'South America Tournaments'],
      ['tournament', 'tournament-ea', 'East Asia Tournaments'],
      ['tournament', 'tournament-sg', 'Southeast Asia Tournaments']
    ].freeze

    TYPES       = DB.map { |region_data| region_data[0] }.uniq.freeze
    SHORT_NAMES = DB.map { |region_data| region_data[1] }.freeze

    attr_reader :name, :short_name, :type

    def initialize(type, short_name, name)
      @type = type
      @short_name = short_name
      @name = name
    end

    def abbreviation
      @short_name
    end

    def eql? other_region
      %i[name short_name type].all? { |a| self.send(a) == other_region.send(a) }
    end

    class << self
      # Makes the contructor private
      private :new

      def find(identifier)
        new(*find_region_data(identifier)) rescue name_error(identifier)
      end
      alias_method :[], :find

      def valid_short_name?(short_name)
        SHORT_NAMES.include?(short_name)
      end

      def validate_short_name!(short_name)
        valid_short_name?(short_name) or name_error(short_name)
      end

      private

      def find_region_data(identifier)
        DB.detect { |data| data[1,2].include?(identifier) }
      end

      def name_error(identifier)
        raise(RegionNameError, "Couldn't find region for '#{identifier}'")
      end
    end
  end

  class RegionNameError < ArgumentError; end
end
