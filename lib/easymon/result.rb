module Easymon
  class Result
    attr_accessor :success
    attr_accessor :message
    attr_accessor :timing
    
    def initialize(result, timing)
      self.success = result[0]
      self.message = result[1]
      self.timing = timing
    end
    
    def success?
      success
    end
    
    def response_status
      success? ? :ok : :service_unavailable
    end
    
    def to_s
        "#{message} - #{Easymon.timing_to_ms(timing)}ms"
    end
    
    def to_json(options = {})
      to_hash.to_json
    end
    
    def to_hash
      {:success => success, :message => message, :timing => timing_to_ms(timing)}
    end
  end
end