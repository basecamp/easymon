require 'test_helper'

class MemcachedCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    check = create_check
    check.run
    
    assert_equal("Up", check.message)
    assert_equal(true, check.success?)
    assert_equal(false, check.failed)
  end
  
  test "#run sets failure conditions on a failed run" do
    Rails.cache.stubs(:write).raises("boom")
    check = create_check
    check.run
    
    assert_equal("Down", check.message)
    assert_equal(true, check.failed)
    assert_equal(false, check.success?)
  end
  
  
  private
  def create_check
    check = Easymon::MemcachedCheck.new(Rails.cache)
    check.name = "Memcached"
    return check
  end
end
