require_relative "censys/version"
require 'rest-client'
require "json"

module Censys
  class Api

    def initialize(uid=nil,secret=nil, options={})
      
      @uri = "https://www.censys.io/api/v1"
      @uid = uid
      @secret = secret

      
      config_file_path = "#{File.dirname(__FILE__)}/../config/config.json"

      # if we weren't passed a config
      unless @uid && @secret
        if File.exist? config_file_path # check to see if a config file exists
          puts "Using config file at #{config_file_path}"
          config = JSON.parse(File.open(config_file_path,"r").read)
          @uid = config["uid"]
          @secret = config["secret"]
        elsif ENV["CENSYS_UID"] && ENV["CENSYS_SECRET"]
          puts "Using Environment variables"
          @uid = ENV["CENSYS_UID"]
          @secret = ENV["CENSYS_SECRET"]
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

    # 80.http.get.headers.server
    def search_ipv4_index(query_string)
      _fetch_paginated_data(query_string, "ipv4")
    end

    def search_certificates_index(query_string)
      _fetch_paginated_data(query_string, "certificates")
    end

    def search_websites_index(query_string)
      _fetch_paginated_data(query_string, "websites")
    end

    private 

    def _fetch_paginated_data(query_string, index)
      Enumerator.new do |yielder|
        page = 1
    
        loop do
          response = _search(query_string,index, page)
    
          if response["status"] == "ok" && page <= response["metadata"]["pages"]
            response["results"].map { |item| yielder << item }
            page += 1
          else
            raise StopIteration
          end

        end
      end.lazy
    end


    # search_type should be one of ipv4, websites, certificates
    def _search(keyword,search_type="certificates",page=1)
      
      payload = {
        :query => keyword,
        :flatten => false,
        :page => 1
      }

      response = RestClient::Request.new(
        :method => :post,
        :url => "#{@uri}/search/#{search_type}",
        :user => @uid,
        :password => @secret,
        :headers => { :accept => :json, :content_type => :json },
        :payload => payload.to_json
      ).execute

    JSON.parse(response.to_str)
    end

# Success Responsees
=begin

{
  "status": "ok",
  "metadata": {
    "count": 127530942,
    "query": "*",
    "backend_time": 263,
    "page": 1,
    "pages": 1275310
  },
  "results": [
    {
      "ip": "173.205.31.126",
      "protocols": [
        "80\/http",
        "443\/https"
      ]
    },
    {
      "ip": "213.149.206.213",
      "protocols": [
        "80\/http"
      ]
    },

    ...

    {
      "ip": "84.206.102.184",
      "protocols": [
        "80\/http"
      ]
    }
  ]
}
=end

# Fail Responsees
=begin
  
400 BAD REQUEST
Your query could not be executed (e.g., query could not be parsed or timed out.) See error for more information.
Example:
{"error_code":400, "error":"query could not be parsed"}

404 NOT FOUND
Specified search index was not valid.
Example:
{"error_code":404, "error":"page not found"}

429 RATE LIMIT EXCEEDED
Your query was not executed because you have exceeded your specified rate limit.
Example:
{"error_code":429, "error":"rate limit exceeded"}

500 INTERNAL SERVER ERROR
An unexpected error occurred when trying to execute your query. Try again at a later time or contact us at support@censys.io if the problem persists.
Example:
{"error_code":500, "error":"unknown error occurred"}
  
=end



  end
end
