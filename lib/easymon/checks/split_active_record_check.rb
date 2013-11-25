module Easymon
  class SplitActiveRecordCheck < Check
    attr_accessor :master
    attr_accessor :slave
    
    def initialize(master, slave, critical=true)
      super()
      
      self.master = master
      self.slave = slave
      self.critical = critical
    end 
    
    def check
      master_up = database_up?(master)
      slave_up = database_up?(slave)
      
      master_status = master_up ? "Master: Up" : "Master: Down"
      slave_status = slave_up ? "Slave: Up" : "Slave: Down"
      
      unless master_up && slave_up
        set_failure
      end
      set_message "#{master_status} - #{slave_status}"
    end
    
    private
      def database_up?(klass)
        1 == klass.connection.select_value("SELECT 1=1").to_i
      rescue
        false
      end
  end
end