require "redis"

module Easymon
  class RedisCheck
    attr_accessor :config
    
    def initialize(config)
      self.config = config
    end 
    
    def check
      check_status = redis_up?
      if check_status
        message = "Up"
      else
        message = "Down"
      end
      [check_status, message]
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