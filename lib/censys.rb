# Working Python
=begin
import sys
import json
import requests

res = requests.get(API_URL + "/data", auth=(UID, SECRET))
if res.status_code != 200:
    print "error occurred: %s" % res.json()["error"]
    sys.exit(1)
for name, series in res.json()["raw_series"].iteritems():
    print series["name"], "was last updated at", series["latest_result"]["timestamp"]
=end

require_relative "censys/version"
require 'rest-client'
require "json"

module Censys
  class Api

    def initialize(uid=nil,secret=nil, options={})
      @uri = "https://www.censys.io/api/v1"

      # TODO - allow proxy configuration here...

      # if we weren't passed a config
      unless uid && secret
        # check to see if a config file exists
        config_file_path = "#{File.dirname(__FILE__)}/../config/config.json"
        if File.exist? config_file_path
          config = JSON.parse(File.open(config_file_path,"r").read)
          @uid = config["uid"]
          @secret = config["secret"]
        else
          raise "Unable to continue... no credentials!"
        end
      end

    end

    def data
      response = RestClient::Request.new(
        :method => :get,
        :url => "#{@uri}/data",
        :user => @uid,
        :password => @secret,
        :headers => { :accept => :json, :content_type => :json }
      ).execute
    results = JSON.parse(response.to_str)
    end

    def search(keyword)
      # "80.http.get.headers.server: Apache"
      payload = {
        "query": keyword
      }

      response = RestClient::Request.new(
        :method => :post,
        :url => "#{@uri}/search/certificates",
        :user => @uid,
        :password => @secret,
        :headers => { :accept => :json, :content_type => :json },
        :payload => payload.to_json
      ).execute
      results = JSON.parse(response.to_str)
    end

  end
end

x = Censys::Api.new.search("intrigue")
