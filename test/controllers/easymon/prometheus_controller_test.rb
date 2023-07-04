require 'test_helper'

module Easymon
  class ChecksControllerTest < ActionController::TestCase

    setup do
      @routes = Easymon::Engine.routes
      Easymon.authorize_with = nil
    end

    test "index" do
      Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
      get :index
      assert response.body.include?("OK"), "Should include 'OK' in response body"
    end
  end
end
