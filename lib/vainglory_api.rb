require 'vainglory_api/client'

# Used to interface with the official Vainglory API
#
# @see https://developer.vainglorygame.com/docs
module VaingloryAPI
  # Alias for VaingloryAPI::Client constructor
  #
  # @see VaingloryAPI::Client#initialize
  def new(*args)
    Client.new(*args)
  end
  module_function :new
end
