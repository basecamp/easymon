require 'test_helper'

class TrafficEnabledCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    # Using a file we know exists in the test
    check = Easymon::TrafficEnabledCheck.new("config/redis.yml")
    check.name = "TrafficEnabled"
    check.run
    
    assert_equal("Traffic is enabled", check.message)
    assert_equal(true, check.success?)
    assert_equal(false, check.failed)
  end
  
  test "#run sets failure conditions on a failed run" do
    check = Easymon::TrafficEnabledCheck.new("traffic_enabled")
    check.name = "Semaphore"
    check.run
    
    assert_equal("Traffic is DISABLED", check.message)
    assert_equal(true, check.failed)
    assert_equal(false, check.success?)
  end
end
