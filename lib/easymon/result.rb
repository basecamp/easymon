module Easymon
  class Result
    attr_accessor :success
    attr_accessor :message
    
    def initialize(result)
      self.success = result[0]
      self.message = result[1]
    end
    
    def success?
      success
    end
    
    def response_status
      success? ? :ok : :service_unavailable
    end
    
    def to_s
        message
    end
    
    def to_json
      to_hash.to_json
    end
    
    def to_hash
      {:success => success, :message => message}
    end
    
  end
end