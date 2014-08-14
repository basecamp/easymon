require "restclient"

module Easymon
  class HttpCheck
    attr_accessor :url
    
    def initialize(url)
      self.url = url
    end 
    
    def check
      check_status = http_up?(url)
      if check_status
        message = "Up"
      else
        message = "Down"
      end
      [check_status, message]
    end
    
    private
      def http_up?(config_url)
        response = RestClient::Request.execute(
                                      :method => :head, 
                                      :url => config_url,
                                      :timeout => 5,
                                      :open_timeout => 5)
        true
      rescue Exception
        false
      end
  end
end