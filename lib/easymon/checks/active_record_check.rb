module Easymon
  class ActiveRecordCheck < Check
    attr_accessor :klass
    
    def initialize(klass, critical=true)
      super()
      
      self.klass = klass
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
        1 == klass.connection.select_value("SELECT 1=1").to_i
      rescue
        false
      end
  end
end