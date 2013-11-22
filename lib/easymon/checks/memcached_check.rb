require "dalli"

module Easymon
  class MemcachedCheck < Check
    attr_accessor :cache
    
    def initialize(cache)
      super()
      
      self.cache = cache
    end 
    
    def check
      if memcached_up?
        status = "Up"
      else
        status = "Down"
        set_failure
      end
      set_message status
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