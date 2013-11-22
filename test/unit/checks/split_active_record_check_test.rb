require 'test_helper'

class SplitActiveRecordCheckTest < ActiveSupport::TestCase
  
  def setup
    # Connection judo to establish an independent connection to a separate db.
    # This is normally done in your app code or something like it. 
    slave_spec = ActiveRecord::Base.configurations["#{Rails.env}_slave"]
    config = ActiveRecord::Base::ConnectionSpecification.new(slave_spec, "#{slave_spec['adapter']}_connection")
    handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
    handler.establish_connection(self.class.name, config)
    @slave_connection = handler.retrieve_connection(SplitActiveRecordCheckTest)
  end
  
  test "#run sets success conditions on successful run" do
    check = create_check
    check.run
    
    assert_equal("Master: Up - Slave: Up", check.message)
    assert_equal(false, check.failed)
    assert_equal(true, check.success?)
  end
  
  test "#run sets failed conditions when slave is down" do
    @slave_connection.stubs(:select_value).raises("boom")
    check = create_check
    check.run
    
    assert_equal("Master: Up - Slave: Down", check.message)
    assert_equal(true, check.failed)
    assert_equal(false, check.success?)
  end
  
  test "#run sets failed conditions when master is down" do
    ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
    check = create_check
    check.run
    
    assert_equal("Master: Down - Slave: Up", check.message)
    assert_equal(true, check.failed)
    assert_equal(false, check.success?)
  end
  
  private
  def create_check
    check = Easymon::SplitActiveRecordCheck.new(ActiveRecord::Base.connection, @slave_connection)
    check.name = "ActiveRecord"
    return check
  end
end
