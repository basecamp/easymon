require "test_helper"

class SplitActiveRecordCheckTest < ActiveSupport::TestCase
  test "#run sets success conditions on successful run" do
    primary = ActiveRecord::Base.connection
    replica = Easymon::Replica.connection

    check = Easymon::SplitActiveRecordCheck.new { [ primary, replica ] }

    results = check.check

    assert_equal("Primary: Up - Replica: Up", results[1])
    assert_equal(true, results[0])
  end

  test "#run sets failed conditions when replica is down" do
    primary = ActiveRecord::Base.connection
    replica = Easymon::Replica.connection

    replica.stubs(:active?).raises("boom")

    check = Easymon::SplitActiveRecordCheck.new { [ primary, replica ] }
    results = check.check

    assert_equal("Primary: Up - Replica: Down", results[1])
    assert_equal(false, results[0])
  end

  test "#run sets failed conditions when primary is down" do
    primary = ActiveRecord::Base.connection
    replica = Easymon::Replica.connection

    primary.stubs(:active?).raises("boom")

    check = Easymon::SplitActiveRecordCheck.new { [ primary, replica ] }
    results = check.check

    assert_equal("Primary: Down - Replica: Up", results[1])
    assert_equal(false, results[0])
  end

  test "given nil as a config" do
    check = Easymon::SplitActiveRecordCheck.new { }
    results = check.check
    assert_equal("Primary: Down - Replica: Down", results[1])
    assert_equal(false, results[0])
  end
end

# This would be done in the host app
module Easymon
  class Replica < ActiveRecord::Base
    establish_connection :primary_replica
  end
end
