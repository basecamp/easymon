require 'test_helper'

module Easymon
  class ChecksControllerTest < ActionController::TestCase

    setup do
      @routes = Easymon::Engine.routes
      Easymon.authorize_with = nil
    end

    test "index when no checks are defined" do
      get :index
      assert_response :service_unavailable
      assert_equal "No Checks Defined", response.body
    end

    test "index when all checks pass" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      get :index
      assert_response :success, "Expected success, got 503: #{response.body}"
      assert response.body.include?("OK"), "Should include 'OK' in response body"
    end

    test "index when a check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      Easymon::Repository.add("redis", Easymon::RedisCheck.new(YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys))
      Redis.any_instance.stubs(:ping).raises("boom")
      get :index
      assert_response :service_unavailable
      assert response.body.include?("redis: Down"), "Should include failure text, got #{response.body}"
      assert response.body.include?("DOWN"), "Should include 'OK' in response body"
    end

    test "index when a critical check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base), :critical)
      ActiveRecord::Base.connection.stubs(:select_value).raises("boom")
      get :index
      assert_response :service_unavailable
      assert response.body.include?("database: Down"), "Should include failure text, got #{response.body}"
    end

    test "index when a non-critical check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base), :critical)
      Easymon::Repository.add("redis", Easymon::RedisCheck.new(YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys))
      Redis.any_instance.stubs(:ping).raises("boom")
      get :index
      assert_response :success
      assert response.body.include?("redis: Down"), "Should include failure text, got #{response.body}"
      assert response.body.include?("OK"), "Should include 'OK' in response body"
    end

    test "index returns valid json" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      get :index, :format => :json

      json = JSON.parse(response.body)

      assert json.has_key?("database")
      assert_equal "Up", json["database"]["message"]
    end

    test "show when the check passes" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      get :show, check: "database"
      assert_response :success
      assert response.body.include?("Up"), "Response should include message text, got #{response.body}"
    end

    test "show json when the check passes" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      get :show, :check => "database", :format => :json

      json = JSON.parse(response.body)

      assert json.has_key?("message")
      assert_equal "Up", json["message"]
    end

    test "show when the check fails" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      ActiveRecord::Base.connection.stubs(:select_value).raises("boom")

      get :show, :check => "database"

      assert_response :service_unavailable
      assert response.body.include?("Down"), "Response should include failure text, got #{response.body}"
    end

    test "show if the check is not found" do
      Easymon::Repository.names.each {|name| Easymon::Repository.remove(name)}

      get :show, :check => "database"
      assert_response :not_found
    end

    test "return 404 if not authorized" do
      Easymon.authorize_with = Proc.new { false }

      get :index
      assert_response :not_found

      get :show, :check => "database"
      assert_response :not_found
    end


  end
end
