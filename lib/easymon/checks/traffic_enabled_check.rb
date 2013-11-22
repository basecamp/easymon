module Easymon
  class TrafficEnabledCheck < SemaphoreCheck
    def check
      if semaphore_exists?
        status = "Traffic is enabled"
      else
        status = "Traffic is DISABLED"
        set_failure
      end
      set_message status
    end
  end
end