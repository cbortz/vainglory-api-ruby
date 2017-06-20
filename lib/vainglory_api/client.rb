require 'json'
require 'ostruct'
require 'openssl'
require 'net/http'
require 'vainglory_api/region'

module VaingloryAPI
  # Used to interface with the official Vainglory API
  #
  # @see https://developer.vainglorygame.com/docs Vainglory API Documentation
  # @see https://developer.vainglorygame.com/docs#payload Vainglory API "Payload"
  # @see https://developer.vainglorygame.com/docs#rate-limits Vainglory API "Rate Limits"
  class Client
    # The base URL used for most requests
    BASE_URL = 'https://api.dc01.gamelockerapp.com'.freeze

    # A new instance of Client.
    #
    # @param (String) api_key your Vainglory API key
    # @param (String) region_identifier the name or short name for your specified Region shard
    # @example Initialize a new client
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    # @return [Client] a new instance of the client
    # @note Requires a valid region short name.
    # @see VaingloryAPI::Region::SHORT_NAMES
    def initialize(api_key, region_identifier = 'na')
      @api_key = api_key
      @region = Region.find(region_identifier)
    end

    # Gets batches of random match data
    #
    # @param [Hash] filter_params the parameters used to filter results
    # @option filter_params [String] 'page[offset]' (0) Allows paging over results
    # @option filter_params [String] 'page[limit]' (50) Values less than 50 and great than 2 are supported.
    # @option filter_params [String] 'sort' (createdAt) By default, Matches are sorted by creation time ascending.
    # @option filter_params [String] 'filter[createdAt-start]' (3hrs ago)  Must occur before end time. Format is iso8601
    # @option filter_params [String] 'filter[createdAt-end]' (Now) Queries search the last 3 hrs. Format is iso8601
    # @example Get samples
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.samples
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#samples Vainglory API "Samples"
    # @see https://developer.vainglorygame.com/docs#pagination Vainglory API "Pagination"
    # @see https://developer.vainglorygame.com/docs#sorting Vainglory API "Sorting"
    def samples(filter_params = {})
      get_request(shard_endpoint_uri('samples', filter_params))
    end

    # Gets data from matches (multiple)
    #
    # @param [Hash] filter_params the parameters used to filter results
    # @option filter_params [String] 'page[offset]' (0) Allows paging over results
    # @option filter_params [String] 'page[limit]' (50) Values less than 50 and great than 2 are supported.
    # @option filter_params [String] 'sort' (createdAt) By default, Matches are sorted by creation time ascending.
    # @option filter_params [String] 'filter[createdAt-start]' (3hrs ago)  Must occur before end time. Format is iso8601
    # @option filter_params [String] 'filter[createdAt-end]' (Now) Queries search the last 3 hrs. Format is iso8601
    # @option filter_params [String] 'filter[playerNames]' Filters by player name, separated by commas.
    # @option filter_params [String] 'filter[playerIds]' Filters by player Id, separated by commas.
    # @option filter_params [String] 'filter[teamNames]' Filters by team names. Team names are the same as the in game team tags.
    # @option filter_params [String] 'filter[gameMode]' Filters by Game Mode
    # @example Get matches
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.matches
    # @example Get matches with a filter
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.matches('filter[playerNames]' => 'player_name')
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#get-a-collection-of-matches Vainglory API "Get a collection of Matches"
    # @see https://developer.vainglorygame.com/docs#rosters Vainglory API "Rosters"
    # @see https://developer.vainglorygame.com/docs#match-data-summary Vainglory API "Match Data Summary"
    # @see https://developer.vainglorygame.com/docs#pagination Vainglory API "Pagination"
    # @see https://developer.vainglorygame.com/docs#sorting Vainglory API "Sorting"
    def matches(filter_params = {})
      get_request(shard_endpoint_uri('matches', filter_params))
    end

    # Gets data for a single match
    #
    # @param [String] match_id the ID of the requested match
    # @example Get a single match
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.match('MATCH_ID')
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#get-a-single-match Vainglory API "Get a single Match"
    # @see https://developer.vainglorygame.com/docs#rosters Vainglory API "Rosters"
    # @see https://developer.vainglorygame.com/docs#match-data-summary Vainglory API "Match Data Summary"
    def match(match_id)
      get_request(shard_endpoint_uri("matches/#{match_id}"))
    end

    # Gets data about players (one or more)
    #
    # @param [String] player_name the in-game name (IGN) of a player
    # @param [String] additional_player_names additional IGNs for search for
    # @example Search for a player
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.players('player_name')
    # @example Search for multiple players
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.players('player_name', 'player_name2')
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#get-a-collection-of-players Vainglory API "Get a collection of players"
    def players(player_name, *additional_player_names)
      player_names  = [player_name].concat(additional_player_names)
      filter_params = { 'filter[playerNames]' => player_names.join(',') }

      get_request(shard_endpoint_uri('players', filter_params))
    end

    # Gets data for a single player
    #
    # @param [String] player_id the ID of the requested player
    # @example Get a single player
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.match('PLAYER_ID')
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#get-a-single-player Vainglory API "Get a single Player"
    def player(player_id)
      get_request(shard_endpoint_uri("players/#{player_id}"))
    end

    # Gets telemtry data from a specified URL
    #
    # @param [String] url the URL of the requested Telemetry data
    # @example Get telemetry data
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.telemetry('TELEMETRY_URL')
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#telemetry Vainglory API "Telemetry"
    def telemetry(url)
      get_request(URI(url), true, false)
    end

    # Gets aggregated lifetime information about teams (multiple)
    #
    # @param [Hash] _filter_params the parameters used to filter results
    # @option _filter_params [String] 'filter[teamNames]' Filters by team name
    # @option _filter_params [String] 'filter[teamIds]' Filters by team ID
    # @raise [NotImplementedError] this endpoint is not yet available
    # @see https://developer.vainglorygame.com/docs#teams-coming-soon Vainglory API "Get a collection of Teams"
    def teams(_filter_params = {})
      raise(NotImplementedError, 'Coming soon!')
    end

    # Gets aggregated lifetime information about a single team
    #
    # @raise [NotImplementedError] this endpoint is not yet available
    # @see https://developer.vainglorygame.com/docs#get-a-single-team Vainglory API "Get a single Team"
    def team(_team_id)
      raise(NotImplementedError, 'Coming soon!')
    end

    # Checks to see if a link object exists for a given code
    #
    # @raise [NotImplementedError] this endpoint is not yet available
    # @see https://developer.vainglorygame.com/docs#links-coming-soon Vainglory API "Links"
    def link(_link_id)
      raise(NotImplementedError, 'Coming soon!')
    end

    # Gets current API version and release date
    #
    # @example Get the API's status information
    #   client = VaingloryAPI::Client.new('API_KEY', 'na')
    #   client.status
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#versioning Vainglory API "Versioning"
    def status
      get_request_without_headers(endpoint_uri('status'))
    end

    private

    def region_identifier
      @region.short_name
    end

    def get_request_without_headers(uri)
      get_request(uri, false)
    end

    def get_request(uri, with_headers = true, with_auth = true)
      req = Net::HTTP::Get.new(uri)
      req = apply_headers(req, with_auth) if with_headers

      request(uri, req)
    end

    def apply_headers(req, with_auth = true)
      req['Authorization'] = "Bearer #{@api_key}" if with_auth
      req['X-TITLE-ID'] = 'semc-vainglory'
      req['Accept'] = 'application/vnd.api+json'

      req
    end

    def request(uri, req)
      http              = Net::HTTP.new(uri.host, uri.port)
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl      = true

      response(http.request(req))
    end

    def shard_endpoint_uri(path, filter_params = {})
      endpoint_uri("shards/#{region_identifier}/#{path}", filter_params)
    end

    def endpoint_uri(path, filter_params = {})
      uri = URI(endpoint_url(path))
      uri.query = URI.encode_www_form(filter_params)

      uri
    end

    def endpoint_url(path)
      [BASE_URL, path].join('/')
    end

    def response(response_data)
      response_object = serialize_response_data(response_data.body)
      metadata        = serialize_response_metadata(response_data)

      # Add metadata members to response_object
      metadata.each do |k, v|
        response_object[k] = v
      end

      response_object
    end

    def serialize_response_metadata(response_data)
      response_code = response_data.code.to_i

      {
        code:           response_code,
        success?:       response_code < 400,
        rate_limit:     response_data['X-RateLimit-Limit'].to_i,
        rate_remaining: response_data['X-RateLimit-Remaining'].to_i,
        rate_reset:     response_data['X-RateLimit-Reset'].to_i,
        raw:            response_data
      }
    end

    def serialize_response_data(raw_response_body)
      data = JSON.parse(raw_response_body, object_class: OpenStruct)

      if data.is_a?(Array)
        OpenStruct.new(data: data)
      else
        data
      end
    end
  end
end
