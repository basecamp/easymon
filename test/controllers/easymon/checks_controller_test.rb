require 'test_helper'

module Easymon
  class ChecksControllerTest < ActionController::TestCase
    
    test "should get index" do
      get :index, use_route: :easymon
      assert_response :success
    end
    
    test "index should return with :ok and success text when all checks pass" do
      get :index, use_route: :easymon
      assert_response :success
    end

    test "index should return with :service_unavailable and failure text when a critical check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
      get :index, use_route: :easymon
      assert_response :service_unavailable
      assert response.body.include?("[Critical] database: Down"), "Should include failure text, got #{response.body}"
    end
    
    test "index should return with :ok and failure text when a non-critical check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      Easymon::Repository.add("redis", Easymon::RedisCheck.new("config/redis.yml"))
      Redis.any_instance.stubs(:ping).raises("boom")
      get :index, use_route: :easymon
      assert_response :success
      assert response.body.include?("redis: Down"), "Should include failure text, got #{response.body}"
    end
    
    test "show should return with :ok and success text when the check passes" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      get :show, use_route: :easymon, :check => "database"
      assert_response :success
      assert response.body.include? "[Critical] database: Up"
    end
    
    test "show should return with :service_unavailable and failure text when the check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
      
      get :show, use_route: :easymon, :check => "database"
      
      assert_response :service_unavailable
      assert response.body.include? "[Critical] database: Down"
    end

  end
end
