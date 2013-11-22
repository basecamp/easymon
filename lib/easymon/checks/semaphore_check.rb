module Easymon
  class SemaphoreCheck < Check
    attr_accessor :file_name
    
    def initialize(file_name)
      super()
      
      self.file_name = file_name
    end 
    
    def check
      if semaphore_exists?
        status = "#{file_name} is in place!"
      else
        status = "#{file_name} does not exist!"
        set_failure
      end
      set_message status
    end
    
    private
      def semaphore_exists?
        Rails.root.join(file_name).exist?
      rescue
        false
      end
  end
end