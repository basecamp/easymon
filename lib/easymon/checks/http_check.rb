require 'net/https'

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
      def http_up?(url)
        http_head(url).is_a?(Net::HTTPSuccess)
      rescue Exception
        false
      end

      def http_head(url)
        uri = URI.parse(url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.is_a?(URI::HTTPS)
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.open_timeout = 5
        http.read_timeout = 5

        http.request Net::HTTP::Head.new(uri.request_uri)
      end
  end
end
