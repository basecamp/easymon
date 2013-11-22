require 'test_helper'

class ActiveRecordCheckTest < ActiveSupport::TestCase
  
  test "#run sets @message to 'Up' on successful run" do
    check = create_check
    check.run
    
    assert_equal(check.message, "Up")
  end
  
  test "#run sets @message to 'Down' on a failed run" do
    ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
    check = create_check
    check.run
    
    assert_equal(check.message, "Down")
  end
  
  test "#run sets @failed on a failed run" do
    ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
    check = create_check
    check.run
    
    assert_equal(check.failed, true)
  end
  
  test "#success? returns false on a failed run" do
    ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
    check = create_check
    check.run
    
    assert_equal(check.success?, false)
  end
  
  test "sets critical to true by default" do
    check = create_check
    
    assert_equal(true, check.critical)
  end
  
  private
  def create_check
    check = Easymon::ActiveRecordCheck.new(ActiveRecord::Base.connection)
    check.name = "ActiveRecord"
    return check
  end
end
