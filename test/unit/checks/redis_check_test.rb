require 'test_helper'

class RedisCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    check = create_check
    check.run
    
    assert_equal("Up", check.message)
    assert_equal(true, check.success?)
    assert_equal(false, check.failed)
  end
  
  test "#run sets failure conditions on a failed run" do
    Redis.any_instance.stubs(:ping).raises("boom")
    check = create_check
    check.run
    
    assert_equal("Down", check.message)
    assert_equal(true, check.failed)
    assert_equal(false, check.success?)
  end
  
  
  private
  def create_check
    # Get us a config hash from disk in this case
    Easymon::RedisCheck.new(YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys)
  end
end
