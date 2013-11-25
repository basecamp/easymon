require "redis"

module Easymon
  class RedisCheck < Check
    attr_accessor :redis
    
    def initialize(redis)
      super()
      self.redis = redis
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
        redis.ping == 'PONG'
      rescue
        false
      end
  end
end