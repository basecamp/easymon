require 'test_helper'

class MemcachedCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    check = create_check
    results = check.check
    
    assert_equal("Up", results[1])
    assert_equal(true, results[0])
  end
  
  test "#run sets failure conditions on a failed run" do
    Rails.cache.stubs(:write).raises("boom")
    check = create_check
    results = check.check
    
    assert_equal("Down", results[1])
    assert_equal(false, results[0])
  end
  
  
  private
  def create_check
    Easymon::MemcachedCheck.new(Rails.cache)
  end
end
