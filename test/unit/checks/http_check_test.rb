require 'test_helper'

class HttpCheckTest < ActiveSupport::TestCase
  test "#run sets success conditions on successful run" do
    Net::HTTP.any_instance.stubs(:request).returns(Net::HTTPSuccess.new(1.1, 200, "OK"))

    check = create_check
    results = check.check

    assert_equal("Up", results[1])
    assert_equal(true, results[0])
  end
  
  test "#run sets failure conditions on a failed run" do
    Net::HTTP.any_instance.stubs(:request).returns(Net::HTTPNotFound.new(1.1, 404, "Not Found"))

    check = create_check
    results = check.check

    assert_equal("Down", results[1])
    assert_equal(false, results[0])
  end

  test "#run sets failure conditions on an errored run" do
    Net::HTTP.any_instance.stubs(:request).raises("boom")

    check = create_check
    results = check.check

    assert_equal("Down", results[1])
    assert_equal(false, results[0])
  end
  
  test "given nil as a url" do
    check = Easymon::HttpCheck.new(nil)
    results = check.check
    assert_equal("Down", results[1])
    assert_equal(false, results[0])
  end

  test "uses the right ssl configuration" do
    Net::HTTP.any_instance.expects(:use_ssl=).with(true)
    Net::HTTP.any_instance.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
    Easymon::HttpCheck.new("https://localhost:9200").check

    Net::HTTP.any_instance.expects(:use_ssl=).with(false)
    Net::HTTP.any_instance.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
    Easymon::HttpCheck.new("http://localhost:9200").check
  end

  test "sends request with basic auth if present" do
    Net::HTTP::Head.any_instance.expects(:basic_auth).with("user", "password")
    Easymon::HttpCheck.new("https://user:password@localhost:9200").check

    Net::HTTP::Head.any_instance.expects(:basic_auth).never
    Easymon::HttpCheck.new("https://localhost:9200").check
  end

  private
  def create_check
    # Fake URL
    Easymon::HttpCheck.new("http://localhost:9200")
  end
end
