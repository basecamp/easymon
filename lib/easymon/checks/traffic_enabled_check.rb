module Easymon
  class TrafficEnabledCheck < SemaphoreCheck
    def check
      check_status = semaphore_exists?
      if check_status
        message = "ENABLED"
      else
        message = "DISABLED"
      end
      [ check_status, message ]
    end
  end
end
