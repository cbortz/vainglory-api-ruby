require 'vainglory_api/client'

# A Ruby libary wrapper for the Vainglory API
#
# @author Chet Bortz
module VaingloryAPI
  # Alias for VaingloryAPI::Client constructor
  #
  # @overload new(api_key, region)
  #   @param api_key (String) your Vainglory API key
  #   @param region (String) the short name for your specified Region shard
  # @param (see VaingloryAPI::Client#initialize)
  # @example Initialize a new client
  #   client = VaingloryAPI.new('API_KEY', 'na')
  # @return [VaingloryAPI::Client] an instance of the client
  # @see VaingloryAPI::Client#initialize
  def self.new(*args)
    Client.new(*args)
  end
end
