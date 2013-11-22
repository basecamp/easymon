require 'test_helper'

class MemcachedCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    check = Easymon::MemcachedCheck.new(Rails.cache)
    results = check.check
    
    assert_equal("Up", results[1])
    assert_equal(true, results[0])
  end
  
  test "#run sets failure conditions on a failed run" do
    Rails.cache.stubs(:write).raises("boom")
    check = Easymon::MemcachedCheck.new(Rails.cache)
    results = check.check
    
    assert_equal("Down", results[1])
    assert_equal(false, results[0])
  end

  test "fails when passed nil as a cache" do
    check = Easymon::MemcachedCheck.new(nil)
    results = check.check

    assert_equal("Down", results[1])
    assert_equal(false, results[0])
  end

  test "fails when passed a cache with no servers" do
    dalli = Dalli::Client.new('', {:namespace => "easymon"})
    check = Easymon::MemcachedCheck.new(dalli)
    results = check.check

    assert_equal("Down", results[1])
    assert_equal(false, results[0])    
  end

end
