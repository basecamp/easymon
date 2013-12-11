require 'test_helper'

class TrafficEnabledCheckTest < ActiveSupport::TestCase
  
  test "#check sets success conditions on successful run" do
    # Using a file we know exists in the test
    check = Easymon::TrafficEnabledCheck.new("config/redis.yml")
    results = check.check

    assert_equal(true, results[0])
    assert_equal("Traffic is enabled", results[1])
  end
  
  test "#check sets failure conditions on a failed run" do
    check = Easymon::TrafficEnabledCheck.new("config/file-does-not-exist")
    results = check.check

    assert_equal(false, results[0])
    assert_equal("Traffic is DISABLED", results[1])
  end
end
