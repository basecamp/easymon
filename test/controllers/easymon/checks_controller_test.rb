require 'test_helper'

module Easymon
  class ChecksControllerTest < ActionController::TestCase
    
    test "should get index" do
      get :index, use_route: :easymon
      assert_response :success
    end
    
    test "index should return with 200 and success text when all checks pass" do
      get :index, use_route: :easymon
      assert_response :success
    end

    test "index should return with 503 and failure text when a critical check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base.connection))
      ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
      get :index, use_route: :easymon
      assert_response 503
      assert response.body.include?("[Critical] database: Down"), "Should include failure text, got #{response.body}"
    end
    
    test "index should return with 200 and failure text when a non-critical check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base.connection))
      Easymon::Repository.add("redis", Easymon::RedisCheck.new("config/redis.yml"))
      Redis.any_instance.stubs(:ping).raises("boom")
      get :index, use_route: :easymon
      assert_response :success
      assert response.body.include?("redis: Down"), "Should include failure text, got #{response.body}"
    end
    
    test "show should return with 200 and success text when the check passes" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base.connection))
      get :show, use_route: :easymon, :check => "database"
      assert_response :success
      assert response.body.include? "[Critical] database: Up"
    end
    
    test "show should return with 503 and failure text when the check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base.connection))
      ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
      
      get :show, use_route: :easymon, :check => "database"
      
      assert_response 503
      assert response.body.include? "[Critical] database: Down"
    end

  end
end
