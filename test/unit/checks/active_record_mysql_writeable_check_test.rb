require "test_helper"

class ActiveRecordMysqlWriteableCheckTest < ActiveSupport::TestCase
  test "#check returns a successful result on a good run" do
    check = create_check
    results = check.check

    assert_equal(true, results[0])
    assert_equal("@@read_only is 0", results[1])
  end

  test "#check returns a failed result on a failed run" do
    # Return a mock'd object that responds to .entries that returns [[0]]
    ActiveRecord::Base.connection.stubs(:execute).returns(mock().stubs(:entries).returns([ [ 1 ] ]))
    check = create_check
    results = check.check

    assert_equal(false, results[0])
    assert_equal("@@read_only is 1", results[1])
  end

  private
  def create_check
    Easymon::ActiveRecordMysqlWriteableCheck.new(ActiveRecord::Base)
  end
end
