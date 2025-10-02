require 'test_helper'

class RedisWriteableCheckTest < ActiveSupport::TestCase

  test "#run sets success conditions on successful run" do
    Redis.any_instance.stubs(:set).returns("OK")
    check = create_check
    results = check.check

    assert_equal("Writeable", results[1])
    assert_equal(true, results[0])
  end

  test "#run sets failure conditions on a failed run" do
    Redis.any_instance.stubs(:set).raises(Redis::ConnectionError.new)
    check = create_check
    results = check.check

    assert_equal("Read Only", results[1])
    assert_equal(false, results[0])
  end

  private
  def create_check
    # Get us a config hash from disk in this case
    Easymon::RedisWriteableCheck.new(YAML.load_file(Rails.root.join("config/redis.yml"), aliases: true)[Rails.env].symbolize_keys)
  end
end
