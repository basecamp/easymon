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

  test "#run uses the health check query when given" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection

    check = Easymon::MultiActiveRecordCheck.new(query: "SELECT 1") do
      { "Primary": primary, "PrimaryReplica": primary_replica }
    end
    results = check.check

    assert_equal("Primary: Up - PrimaryReplica: Up", results[1])
    assert_equal(true, results[0])
  end

  test "#run sets failed conditions when the health check query returns false" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection

    primary_replica.stubs(:select_value).with("SELECT 1").returns(0)

    check = Easymon::MultiActiveRecordCheck.new(query: "SELECT 1") do
      { "Primary": primary, "PrimaryReplica": primary_replica }
    end
    results = check.check

    assert_equal("Primary: Up - PrimaryReplica: Down", results[1])
    assert_equal(false, results[0])
  end

  test "#run sets failed conditions when the health check query returns null" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection

    check = Easymon::MultiActiveRecordCheck.new(query: "SELECT NULL") do
      { "Primary": primary, "PrimaryReplica": primary_replica }
    end
    results = check.check

    assert_equal("Primary: Down - PrimaryReplica: Down", results[1])
    assert_equal(false, results[0])
  end

  test "#run sets failed conditions when the health check query raises" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection

    primary_replica.stubs(:select_value).raises("boom")

    check = Easymon::MultiActiveRecordCheck.new(query: "SELECT 1") do
      { "Primary": primary, "PrimaryReplica": primary_replica }
    end
    results = check.check

    assert_equal("Primary: Up - PrimaryReplica: Down", results[1])
    assert_equal(false, results[0])
  end

  test "#run uses per-connection queries when given" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection
    other_replica = Easymon::OtherReplica.connection

    primary_replica.stubs(:select_value).with("SELECT 0").returns(0)

    check = Easymon::MultiActiveRecordCheck.new do
      {
        "Primary": [ primary, "SELECT 1" ],
        "PrimaryReplica": [ primary_replica, "SELECT 0" ],
        "OtherReplica": other_replica
      }
    end
    results = check.check

    assert_equal("Primary: Up - PrimaryReplica: Down - OtherReplica: Up", results[1])
    assert_equal(false, results[0])
  end

  test "#run prefers the per-connection query over the default query" do
    primary = ActiveRecord::Base.connection
    primary_replica = Easymon::PrimaryReplica.connection

    primary_replica.stubs(:select_value).with("SELECT 0").returns(0)

    check = Easymon::MultiActiveRecordCheck.new(query: "SELECT 1") do
      {
        "Primary": primary,
        "PrimaryReplica": [ primary_replica, "SELECT 0" ]
      }
    end
    results = check.check

    assert_equal("Primary: Up - PrimaryReplica: Down", results[1])
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
