require 'test_helper'

class ChecklistTest < ActiveSupport::TestCase
  def setup
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base.connection))
    Easymon::Repository.add("redis", Easymon::RedisCheck.new("config/redis.yml"))
    Easymon::Repository.add("memcached", Easymon::MemcachedCheck.new(Rails.cache))
  end
  
  test "it knows the number of checks in the Repository" do
    checklist = Easymon::Repository.all
    
    assert_equal 3, checklist.checks.size
  end
  
  test "it will run each check" do
    checklist = Easymon::Repository.all
    assert_equal false, checklist.checks.all?(&:has_run)
    
    checklist.run
    assert_equal true, checklist.checks.all?(&:has_run)
  end
  
  test "it knows if there are critical checks in the repository" do
    checklist = Easymon::Repository.all
    
    assert_equal true, checklist.has_critical?
  end
  
  test "it knows if the critical checks were successful" do
    checklist = Easymon::Repository.all
    checklist.run
    
    assert_equal true, checklist.critical_success?
  end
  
  test "it knows if the critical checks were not successful" do
    checklist = Easymon::Repository.all
    ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
    checklist.run
    
    assert_equal false, checklist.critical_success?
  end
end