require 'ostruct'

module VaingloryAPI
  # Helper class for metadata pertaining to regions
  #
  # @see https://developer.vainglorygame.com/docs#regions Vainglory API "Regions"
  class Region
    # Arrays of metadata about each region
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

    # Unique Region types (general, tournament, etc...) extracted from DB metadata
    TYPES = DB.map { |region_data| region_data[0] }.uniq.freeze

    # Valid short names (na, eu, etc...) extracted from DB metadata
    SHORT_NAMES = DB.map { |region_data| region_data[1] }.freeze

    attr_reader :name, :short_name, :type

    # A new instance of Region.
    #
    # @param (String) type the type of region (general, tournament, etc...)
    # @param (String) short_name the short name of the region
    # @param (String) name the name of the region
    # @return [Region] a new instance of a Region
    # @note Instantiation is private
    def initialize(type, short_name, name)
      @type = type
      @short_name = short_name
      @name = name
    end

    # Alias method for short name
    #
    # @return [String] the "short name" of the region
    def abbreviation
      @short_name
    end

    # Compares region to another region.
    #
    # @example Compare two regions
    #   VaingloryAPI::Region['na'].eql? VaingloryAPI::Region['na'] # => true
    #   VaingloryAPI::Region['na'].eql? VaingloryAPI::Region['sg'] # => false
    # @param [VaingloryAPU::Region] other_region another region to compare for quality
    # @return [Boolean] whether all attributes match
    def eql? other_region
      %i[name short_name type].all? { |a| self.send(a) == other_region.send(a) }
    end

    class << self
      # Makes the contructor private
      private :new

      # Find a region by name or abbreviation ("short name")
      #
      # @example Finding a region
      #   VaingloryAPI::Region.find('eu')
      # @example Finding a region (alternative syntax)
      #   VaingloryAPI::Region['eu'] # => <VaingloryAPI::Region ...>
      # @param [String] identifier the target name or abbreviation of the region
      # @return [Region] if the identifier is found
      # @raise [VaingloryAPI::RegionNameError] if the identifier is not found
      # @see DB
      # @see SHORT_NAMES
      def find(identifier)
        new(*find_region_data(identifier)) rescue name_error(identifier)
      end
      alias_method :[], :find

      # Checks if short name is known
      #
      # @example Checking if a short name is valid
      #   VaingloryAPI::Region.valid_short_name?('na') # => true
      #   VaingloryAPI::Region.valid_short_name?('QQ') # => false
      # @param [String] short_name the short name of a desired region
      # @return [Boolean] whether the short name is known
      def valid_short_name?(short_name)
        SHORT_NAMES.include?(short_name)
      end

      # Validates a short name
      #
      # @example Validating a short name
      #   VaingloryAPI::Region.validate_short_name!('na') # => true
      #   VaingloryAPI::Region.validate_short_name!('QQ') # VaingloryAPI::RegionNameError
      # @param [String] short_name the short name of a desired region
      # @return [True] if the short name is valid
      # @raise [VaingloryAPI::RegionNameError] if the short name is invalid
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

  # Helper exception class used to notify user of invalid names
  class RegionNameError < ArgumentError; end
end
