require "redis"

module Easymon
  class RedisCheck < Check
    attr_accessor :config
    
    def initialize(config_file)
      super()
      
      self.config = YAML.load_file(Rails.root.join(config_file))[Rails.env].symbolize_keys
    end 
    
    def check
      if redis_up?
        status = "Up"
      else
        status = "Down"
        set_failure
      end
      set_message status
    end
    
    private
      def redis_up?
        redis = Redis.new(config)
        redis.ping == 'PONG'
      rescue
        false
      end
  end
end