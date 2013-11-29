require 'test_helper'

class RedisCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    check = create_check
    results = check.check
    
    assert_equal("Up", results[1])
    assert_equal(true, results[0])
  end
  
  test "#run sets failure conditions on a failed run" do
    Redis.any_instance.stubs(:ping).raises("boom")
    check = create_check
    results = check.check
    
    assert_equal("Down", results[1])
    assert_equal(false, results[0])
  end
  
  
  private
  def create_check
    # Get us a config hash from disk in this case
    Easymon::RedisCheck.new(YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys)
  end
end
