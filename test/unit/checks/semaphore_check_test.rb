require 'test_helper'

class SemaphoreCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    check = Easymon::SemaphoreCheck.new("config/redis.yml")
    results = check.check

    assert_equal(true, results[0])
    assert_equal("config/redis.yml is in place!", results[1])
  end
  
  test "#run sets failure conditions on a failed run" do
    check = Easymon::SemaphoreCheck.new("config/file-does-not-exist")
    results = check.check

    assert_equal(false, results[0])
    assert_equal("traffic_enabled does not exist!", results[1])
  end
end
