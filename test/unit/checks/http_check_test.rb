require 'test_helper'

class HttpCheckTest < ActiveSupport::TestCase
  
  test "#run sets success conditions on successful run" do
    RestClient::Request.any_instance.stubs(:execute).returns(true)
    check = create_check
    results = check.check
    
    assert_equal("Up", results[1])
    assert_equal(true, results[0])
  end
  
  test "#run sets failure conditions on a failed run" do
    RestClient::Request.any_instance.stubs(:execute).raises("boom")
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
  
  
  private
  def create_check
    # Fake URL
    Easymon::HttpCheck.new("http://localhost:9200")
  end
end
