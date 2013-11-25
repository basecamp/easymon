require "redis"

module Easymon
  class RedisCheck < Check
    attr_accessor :config
    
    def initialize(config)
      super()
      
      self.config = config
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
        redis = Redis.new(@config)
        reply = redis.ping == 'PONG'
        redis.client.disconnect
        reply
      rescue
        false
      end
  end
end