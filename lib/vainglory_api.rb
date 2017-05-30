require 'vainglory_api/client'

module VaingloryAPI
  def new(*args)
    Client.new(*args)
  end
  module_function :new
end
