require 'test_helper'

class ChecklistTest < ActiveSupport::TestCase
  def setup
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
    Easymon::Repository.add("redis", Easymon::RedisCheck.new(YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys))
    Easymon::Repository.add("memcached", Easymon::MemcachedCheck.new(Rails.cache))
  end
  
  test "it knows the number of checks in the Repository" do
    checklist = Easymon::Repository.all
    
    assert_equal 3, checklist.size
  end
  
  test "it will run each check" do
    checklist = Easymon::Repository.all
    
    checklist.check
    assert_equal checklist.size, checklist.results.size
  end
  
  test "#to_s returns a valid representation of the checklist" do
    checklist = Easymon::Repository.all
    
    checklist.check
    checklist.items.keys.each do |name|
      assert checklist.to_s.include?("#{name}: Up"), "#to_s doesn't include '#{name}: Up'"
    end
  end
  
  test "#to_json returns a valid json representation of the checklist" do
    checklist = Easymon::Repository.all
    
    checklist.check
    assert_equal "[{\"success\":true,\"message\":\"Up\",\"name\":\"database\"},{\"success\":true,\"message\":\"Up\",\"name\":\"redis\"},{\"success\":true,\"message\":\"Up\",\"name\":\"memcached\"}]", checklist.to_json
  end
  
  test "#response_status returns :ok when all checks pass" do
    checklist = Easymon::Repository.all
    
    checklist.check
    assert_equal :ok, checklist.response_status
  end
  
  test "#response_status returns :service_unavailable when a check fails" do
    Redis.any_instance.stubs(:ping).raises("boom")
    checklist = Easymon::Repository.all
    
    checklist.check
    assert_equal :service_unavailable, checklist.response_status
  end
  
  test "#success? returns false when results is empty" do
    checklist = Easymon::Repository.all
    
    assert_equal false, checklist.success?
  end
  
  test "can look up checks by name" do
    checklist = Easymon::Repository.all
    
    assert checklist.include?("database")
  end
  
  test "cat fetch a check by name" do
    checklist = Easymon::Repository.all
    
    assert checklist.fetch("database").instance_of? Easymon::ActiveRecordCheck
  end
end