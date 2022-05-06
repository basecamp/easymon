module Easymon
  class ActiveRecordMysqlWriteableCheck
    attr_accessor :klass

    def initialize(klass)
      self.klass = klass
    end

    def check
      check_status = database_writeable?
      if check_status
        message = "@@read_only is 0"
      else
        message = "@@read_only is 1"
      end
      [check_status, message]
    end

    private
      def database_writeable?
        klass.connection.execute("SELECT @@read_only").entries.flatten.first == 0
      rescue
        false
      end
  end
end
