module Easymon
  class Check
    attr_accessor :name
    
    # Set by check
    attr_accessor :message
    attr_accessor :failed
    attr_accessor :critical
    attr_accessor :has_run

    def initialize
      self.critical = false if self.critical.nil?
      self.has_run = false
    end
    
    def run
      clear_state
      check
      self.has_run = true
    end
    
    def set_message(message)
      self.message = message
    end
    
    def set_failure
      self.failed = true
    end
    
    def to_s
      if critical
        "[Critical] #{name}: #{message}"
      else
        "#{name}: #{message}"
      end
    end
    
    def to_json(*args)
      to_hash.to_json
    end
    
    def to_hash
      {name => message, "critical" => critical ? true : false}
    end
    
    def success?
      has_run and not failed
    end
    
    def response_status
      success? ? :ok : :service_unavailable
    end
    
    private
    
      def check
        raise(NotImplementedError, "Your check must implement it's own #check method")
      end
      
      def clear_state
        self.failed = false
        self.message = nil
      end
  end
end