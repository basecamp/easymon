require "redis"

module Easymon
  class RedisWriteableCheck
    attr_accessor :config

    def initialize(config)
      self.config = config
    end

    def check
      check_status = redis_writeable?
      message = check_status ? "Writeable" : "Read Only"

      [check_status, message]
    end

    private
      def redis_writeable?
        redis = Redis.new(@config)
        key = "easymon_#{Time.now.to_i}"
        reply = redis.set(key, "true")
        redis.del(key)

        reply == "OK"
      rescue
        false
      ensure
        if redis.respond_to? :close
          redis.close              # Redis 4+
        else
          redis.client.disconnect  # Older redis
        end
      end
  end
end
