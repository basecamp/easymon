module Easymon
  class ActiveRecordCheck < Check
    attr_accessor :connection
    
    def initialize(connection, critical=true)
      super()
      
      self.connection = connection
      self.critical = critical
    end 
    
    def check
      if database_up?
        status = "Up"
      else
        status = "Down"
        set_failure
      end
      set_message status
    end
    
    private
      def database_up?
        1 == connection.select_value("SELECT 1=1").to_i
      rescue
        false
      end
  end
end