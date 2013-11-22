require 'test_helper'

class SemaphoreCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    check = Easymon::SemaphoreCheck.new("config/redis.yml")
    check.name = "Semaphore"
    check.run
    
    assert_equal("config/redis.yml is in place!", check.message)
    assert_equal(true, check.success?)
    assert_equal(false, check.failed)
  end
  
  test "#run sets failure conditions on a failed run" do
    check = Easymon::SemaphoreCheck.new("traffic_enabled")
    check.name = "Semaphore"
    check.run
    
    assert_equal("traffic_enabled does not exist!", check.message)
    assert_equal(true, check.failed)
    assert_equal(false, check.success?)
  end
end
