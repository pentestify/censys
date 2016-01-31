require_relative "censys/version"
require "json"

module Censys
  class API

    def initialize(uid=nil,secret=nil)
      uri = "https://www.censys.io/api/v1"


      unless uid && secret
        config_file = "#{File.dirname(__FILE__)}/../config/config.json"
        config = JSON.parse(File.open(config_file,"r").read)
        uid = config["uid"]
        secret = config["secret"]
      end
      puts "UID #{uid}"
      puts "SECRET #{secret}"
    end
  end
end


Censys::API.new
