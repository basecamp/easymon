require "elastic"

module Easymon
  class ElasticsearchCheck
    attr_accessor :config
    
    def initialize(config)
      self.config = config
    end 
    
    def check
      check_status = elasticsearch_up?(config[:url])
      if check_status
        message = "Up"
      else
        message = "Down"
      end
      [check_status, message]
    end
    
    private
      def elasticsearch_up?(config_url)
        elasticsearch = Elastic::Client.new(config_url)
        elasticsearch.ping
      rescue
        false
      end
  end
end