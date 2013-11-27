require "dalli"

module Easymon
  class MemcachedCheck
    attr_accessor :cache
    
    def initialize(cache)
      self.cache = cache
    end 
    
    def check
      check_status = memcached_up?
      if check_status
        message = "Up"
      else
        message = "Down"
      end
      [check_status, message]
    end
    
    private
      def memcached_up?
        cache.write "health_check", 1
        1 == cache.read("health_check")
      rescue
        false
      end
  end
end