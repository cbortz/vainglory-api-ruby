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

    # @return [String] the name of the region
    attr_reader :name

    # @return [String] the short name of the region
    attr_reader :short_name

    # @return [String] the type of region
    attr_reader :type

    # A new instance of Region.
    #
    # @param (String) identifier the name or short name of a region
    # @return [Region] a new instance of a Region
    # @raise [VaingloryAPI::RegionNameError] if the identifier is not found
    # @see SHORT_NAMES
    # @see DB
    def initialize(identifier)
      data        = self.class.detect_region_info(identifier)
      @type       = data[0]
      @short_name = data[1]
      @name       = data[2]
    rescue NoMethodError
      raise(RegionNameError, "Couldn't find region for '#{identifier}'")
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
    # @param [VaingloryAPU::Region] other another region to compare for quality
    # @return [Boolean] whether all attributes match
    def eql?(other)
      %i(name short_name type).all? { |a| send(a) == other.send(a) }
    end

    class << self
      alias find new
      alias [] new

      # Checks if short name is known
      #
      # @example Checking if a short name is valid
      #   VaingloryAPI::Region.valid_short_name?('na') # => true
      #   VaingloryAPI::Region.valid_short_name?('QQ') # => false
      # @param [String] short_name the short name of a desired region
      # @return [Boolean] whether the short name is known
      # @see SHORT_NAMES
      # @see DB
      def valid_short_name?(short_name)
        SHORT_NAMES.include?(short_name)
      end

      # Detects region data from DB constant
      #
      # @example Detecting region data from DB
      #   VaingloryAPI::Region.detech_region_info('na')
      # @param [String] identifier the name or short name of the desired region
      # @return [Array] if region data is found
      # @return [nil] if region data is not found
      # @see DB
      def detect_region_info(identifier)
        DB.detect { |region_data| region_data[1, 2].include?(identifier) }
      end
    end
  end

  # Helper exception class used to notify user of invalid names
  class RegionNameError < ArgumentError; end
end
