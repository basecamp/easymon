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
        1 == klass.connection.select_value("SELECT 1").to_i
      rescue
        false
      end
  end
end
