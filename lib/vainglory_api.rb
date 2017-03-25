require 'json'
require 'ostruct'
require 'openssl'
require 'net/http'

class VaingloryAPI
  BASE_URL = "https://api.dc01.gamelockerapp.com"

  class << self
    def status
      get_request_without_headers(endpoint_uri('status'))
    end

    def samples(filter_params = {})
      get_request(endpoint_uri('shards/na/samples', filter_params))
    end

    def matches(filter_params = {})
      get_request(endpoint_uri('shards/na/matches', filter_params))
    end

    def match(match_id)
      get_request(endpoint_uri("shards/na/matches/#{match_id}"))
    end

    def players(*names)
      params = {"filter[playerNames]" => names.join(',')}
      get_request(endpoint_uri('shards/na/players', params))
    end

    def player(player_id)
      get_request(endpoint_uri("shards/na/players/#{player_id}"))
    end

    def telemetry(url)
      get_request(URI(url), true, false)
    end

    def teams(filter_params = {})
      raise(NotImplementedError, "Coming soon!")
    end

    def team(team_id)
      raise(NotImplementedError, "Coming soon!")
    end

    def link(link_id)
      raise(NotImplementedError, "Coming soon!")
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
      req['Authorization'] = "Bearer #{ENV['API_KEY']}" if with_auth
      req['X-TITLE-ID'] = "semc-vainglory"
      req['Accept'] = "application/vnd.api+json"

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
      OpenStruct.new({
        success?:       response_data.code.to_i < 200,
        rate_limit:     response_data['X-RateLimit-Limit'].to_i,
        rate_remaining: response_data['X-RateLimit-Remaining'].to_i,
        rate_reset:     response_data['X-RateLimit-Reset'].to_i,
        data:           JSON.parse(response_data.body, object_class: OpenStruct),
        raw:            response_data
      })
    end
  end
end
