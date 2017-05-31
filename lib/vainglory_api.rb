require 'vainglory_api/client'

# Used to interface with the official Vainglory API
#
# @see https://developer.vainglorygame.com/docs
module VaingloryAPI
  # Alias for VaingloryAPI::Client constructor
  #
  # @param (see VaingloryAPI::Client#initialize)
  # @example Initialize a new client
  #   client = VaingloryAPI.new('API_KEY', 'na')
  # @return [VaingloryAPI::Client] an instance of the client
  # @see VaingloryAPI::Client#initialize
  def new(*args)
    Client.new(*args)
  end
  module_function :new
end
