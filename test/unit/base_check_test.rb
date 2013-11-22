require 'test_helper'

class BaseCheckTest < ActiveSupport::TestCase
  
  test "base object throws exception when run if not subclassed" do
    check = create_check
    
    exception = assert_raises NotImplementedError do
      check.run
    end
    
    assert_equal("Your check must implement it's own #check method", exception.message)
  end
  
  test "#to_s outputs the check name and message" do
    check = create_check
    
    assert_equal check.to_s, "ActiveRecord: Works Great!"
  end
  
  test "#to_s outputs the criticality, check name and message when critical" do
    check = create_check
    check.critical = true
    
    assert_equal check.to_s, "[Critical] ActiveRecord: Works Great!"
  end
  
  test "#to_hash outputs a hash" do
    check = create_check
    
    assert_equal check.to_hash, {"ActiveRecord" => "Works Great!", "critical" => false}
  end
  
  test "#to_json outputs json" do
    check = create_check
    
    assert_equal check.to_json, "{\"ActiveRecord\":\"Works Great!\",\"critical\":false}"
  end
  
  test "#set_message sets the instance variable @message" do
    check = create_check
    check.set_message "ActiveSupport"
    
    assert_equal(check.message, "ActiveSupport")
  end
  
  test "#set_failure sets the instance variable @failed" do
    check = create_check
    check.set_failure
    
    assert_equal(true, check.failed)
  end
  
  test "#success returns true when @failed has not been set" do
    check = create_check
    check.has_run = true
    
    assert_equal(true, check.success?)
  end
  
  test "#success returns false when #set_failure has been called" do
    check = create_check
    check.set_failure
    check.has_run = true
    
    assert_equal(false, check.success?)
  end
  
  test "#success returns false when the check hasn't been run" do
    check = create_check
    
    assert_equal(false, check.success?)
  end
  
  test "#critical returns false when not set" do
    check = create_check
    
    assert_equal(check.critical, false)
  end
  
  test "has_run is false by default" do
    check = create_check
    
    assert_equal(false, check.has_run)
  end
  
  test "has_run is set by #run" do
    check = create_check
    check.stubs(:check).returns(true)
    check.run
    
    assert_equal(true, check.has_run)
  end
  
  private
  def create_check
    check = Easymon::Check.new
    check.name = "ActiveRecord"
    check.message = "Works Great!"
    return check
  end
end
