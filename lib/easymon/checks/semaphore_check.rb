module Easymon
  class SemaphoreCheck
    attr_accessor :file_name
    
    def initialize(file_name)
      self.file_name = file_name
    end 
    
    def check
      check_status = semaphore_exists?
      if check_status
        message = "#{file_name} is in place!"
      else
        message = "#{file_name} does not exist!"
      end
      [check_status, message]
    end
    
    private
      def semaphore_exists?
        Rails.root.join(file_name).exist?
      rescue
        false
      end
  end
end