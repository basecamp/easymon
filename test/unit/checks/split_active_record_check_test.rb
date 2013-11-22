require 'test_helper'

class SplitActiveRecordCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    master = ActiveRecord::Base.connection
    Easymon::Base.establish_connection
    slave = Easymon::Base.connection
    
    check = Easymon::SplitActiveRecordCheck.new { [master, slave] }
    
    results = check.check
    
    assert_equal("Master: Up - Slave: Up", results[1])
    assert_equal(true, results[0])
  end
  
  test "#run sets failed conditions when slave is down" do
    master = ActiveRecord::Base.connection
    Easymon::Base.establish_connection
    slave = Easymon::Base.connection

    slave.stubs(:select_value).raises("boom")
    
    check = Easymon::SplitActiveRecordCheck.new { [master, slave] }
    results = check.check

    assert_equal("Master: Up - Slave: Down", results[1])
    assert_equal(false, results[0])
  end
  
  test "#run sets failed conditions when master is down" do
    master = ActiveRecord::Base.connection
    Easymon::Base.establish_connection
    slave = Easymon::Base.connection

    master.stubs(:select_value).raises("boom")
    
    check = Easymon::SplitActiveRecordCheck.new { [master, slave] }
    results = check.check
    
    assert_equal("Master: Down - Slave: Up", results[1])
    assert_equal(false, results[0])
  end
  
  test "given nil as a config" do
    check = Easymon::SplitActiveRecordCheck.new { }
    results = check.check
    assert_equal("Master: Down - Slave: Down", results[1])
    assert_equal(false, results[0])
  end
end

# This would be done in the host app
module Easymon
  class Base < ActiveRecord::Base
    def establish_connection(spec = nil)
      if spec
        super
      elsif config = Easymon.database_configuration
        super config
      end
    end
    
    def database_configuration
      env = "#{Rails.env}_slave"
      config = YAML.load_file(Rails.root.join('config/database.yml'))[env]
    end
  end
end
