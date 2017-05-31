require 'json'
require 'ostruct'
require 'openssl'
require 'net/http'

module VaingloryAPI
  class Client
    # The base URL used for *most* requests
    BASE_URL = 'https://api.dc01.gamelockerapp.com'.freeze

    def initialize(api_key, region = 'na')
      @api_key = api_key
      @region = region
    end

    # Gets batches of random match data
    #
    # @param [Hash] filter_params the parameters used to filter results (optional)
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#samples
    def samples(filter_params = {})
      get_request(endpoint_uri("shards/#{@region}/samples", filter_params))
    end

    # Gets data from matches (multiple)
    #
    # @param [Hash] filter_params the parameters used to filter results (optional)
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#participants
    def matches(filter_params = {})
      get_request(endpoint_uri("shards/#{@region}/matches", filter_params))
    end

    # Gets data for a single match
    #
    # @param [String] match_id the ID of the requested match
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#get-a-single-match
    def match(match_id)
      get_request(endpoint_uri("shards/#{@region}/matches/#{match_id}"))
    end

    # Gets data about players (one or more)
    #
    # @param [String] player_name the in-game name (IGN) of a player
    # @param [String] additional_player_names additional IGNs for search for
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#get-a-collection-of-players
    def players(player_name, *additional_player_names)
      player_names = [player_name].concat(additional_player_names)
      filter_params = { 'filter[playerNames]' => player_names.join(',') }
      get_request(endpoint_uri("shards/#{@region}/players", filter_params))
    end

    # Gets data for a single player
    #
    # @param [String] player_id the ID of the requested player
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#get-a-single-player
    def player(player_id)
      get_request(endpoint_uri("shards/#{@region}/players/#{player_id}"))
    end

    # Gets telemtry data from a specified URL
    #
    # @param [String] url the URL of the requested Telemetry data
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#telemetry
    def telemetry(url)
      get_request(URI(url), true, false)
    end

    # Gets aggregated lifetime information about teams (multiple)
    #
    # @raise [NotImplementedError] this endpoint is not yet available
    # @see https://developer.vainglorygame.com/docs#teams-coming-soon
    def teams(_filter_params = {})
      raise(NotImplementedError, 'Coming soon!')
    end

    # Gets aggregated lifetime information about a single team
    #
    # @raise [NotImplementedError] this endpoint is not yet available
    def team(_team_id)
      raise(NotImplementedError, 'Coming soon!')
    end

    # Checks to see if a link object exists for a given code
    #
    # @raise [NotImplementedError] this endpoint is not yet available
    # @see https://developer.vainglorygame.com/docs#links-coming-soon
    def link(_link_id)
      raise(NotImplementedError, 'Coming soon!')
    end

    # Gets current API version and release date
    #
    # @return [OpenStruct] the response and metadata
    # @see https://developer.vainglorygame.com/docs#versioning
    def status
      get_request_without_headers(endpoint_uri('status'))
    end

    private

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
        success?:       response_code < 300,
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
