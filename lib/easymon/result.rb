module Easymon
  class Result
    attr_accessor :success
    attr_accessor :message
    attr_accessor :timing
    attr_accessor :critical

    def initialize(result, timing, is_critical = false)
      self.success = result[0]
      self.message = result[1]
      self.timing = timing
      self.critical = is_critical
    end

    def success?
      success
    end

    def is_critical?
      critical
    end

    def response_status
      success? ? :ok : :service_unavailable
    end

    def to_s
        "#{message} - #{Easymon.timing_to_ms(timing)}ms"
    end

    def as_json(options = {})
      to_hash
    end

    def to_hash
      { success: success, message: message, timing: Easymon.timing_to_ms(timing), critical: critical }
    end
  end
end
