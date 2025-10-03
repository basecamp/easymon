require "test_helper"

class MultiActiveRecordCheckTest < ActiveSupport::TestCase
  test "#run sets success conditions on successful run" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection
    other_replica = Easymon::OtherReplica.connection

    check = Easymon::MultiActiveRecordCheck.new do
      {
        "Primary": primary, "PrimaryReplica": primary_replica, "OtherReplica": other_replica
      }
    end
    results = check.check

    assert_equal("Primary: Up - PrimaryReplica: Up - OtherReplica: Up", results[1])
    assert_equal(true, results[0])
  end

  test "#run sets failed conditions when replica is down" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection
    other_replica = Easymon::OtherReplica.connection

    primary_replica.stubs(:active?).raises("boom")

    check = Easymon::MultiActiveRecordCheck.new do
      {
        "Primary": primary, "PrimaryReplica": primary_replica, "OtherReplica": other_replica
      }
    end
    results = check.check

    assert_equal("Primary: Up - PrimaryReplica: Down - OtherReplica: Up", results[1])
    assert_equal(false, results[0])
  end

  test "#run sets failed conditions when primary is down" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection
    other_replica = Easymon::OtherReplica.connection

    primary.stubs(:active?).raises("boom")

    check = Easymon::MultiActiveRecordCheck.new do
      {
        "Primary": primary, "PrimaryReplica": primary_replica, "OtherReplica": other_replica
      }
    end
    results = check.check

    assert_equal("Primary: Down - PrimaryReplica: Up - OtherReplica: Up", results[1])
    assert_equal(false, results[0])
  end

  test "given nil as a config" do
    check = Easymon::MultiActiveRecordCheck.new { }
    results = check.check
    assert_equal("", results[1])
    assert_equal(false, results[0])
  end
end

# This would be done in the host app
module Easymon
  class PrimaryReplica < ActiveRecord::Base
    establish_connection :primary_replica
  end

  class OtherReplica < ActiveRecord::Base
    establish_connection :other_replica
  end
end
