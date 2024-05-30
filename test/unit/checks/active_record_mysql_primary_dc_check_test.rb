require 'test_helper'

class ActiveRecordMysqlPrimaryDcCheckTest < ActiveSupport::TestCase

  test "#check returns a successful result on a good run" do
    # We use this stub to control what @@report_host returns from the ActiveRecord execute call
    ActiveRecord::Base.connection.stubs(:execute).returns([["db-01.dc1.domain.tld"]])

    check = create_check
    results = check.check

    assert_equal(true, results[0])
    assert_equal("MySQL primary datacenter is: dc1", results[1])
  end

  test "#check returns a failed result on a failed run" do
    # We use this stub to control what @@report_host returns from the ActiveRecord execute call
    ActiveRecord::Base.connection.stubs(:execute).returns([["db-01.dc2.domain.tld"]])

    check = create_check
    results = check.check

    assert_equal(false, results[0])
    assert_equal("MySQL primary datacenter is: dc2", results[1])
  end

  private
  def create_check
    Easymon::ActiveRecordMysqlPrimaryDcCheck.new(ActiveRecord::Base, { datacenter: "dc1" })
  end
end
