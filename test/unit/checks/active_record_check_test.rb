require 'test_helper'

class ActiveRecordCheckTest < ActiveSupport::TestCase
  
  test "#check returns a successful result on a good run" do
    check = create_check
    results = check.check
    
    assert_equal(true, results[0])
    assert_equal("Up", results[1])
  end
  
  test "#check returns a failed result on a failed run" do
    ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
    check = create_check
    results = check.check
    
    assert_equal(false, results[0])
    assert_equal("Down", results[1])
  end
  
  test "given nil as a config" do
    check = Easymon::ActiveRecordCheck.new(nil)
    results = check.check
    assert_equal("Down", results[1])
    assert_equal(false, results[0])
  end
  
  private
  def create_check
    Easymon::ActiveRecordCheck.new(ActiveRecord::Base)
  end
end
