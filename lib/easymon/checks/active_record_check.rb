module Easymon
  class ActiveRecordCheck
    attr_accessor :klass
    
    def initialize(klass)
      self.klass = klass
    end 
    
    def check
      check_status = database_up?
      if check_status
        message = "Up"
      else
        message = "Down"
      end
      [check_status, message]
    end
    
    private
      def database_up?
        klass.connection.connect!
        klass.connection.active?
      rescue
        false
      end
  end
end
