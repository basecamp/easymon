require 'test_helper'

class SplitActiveRecordCheckTest < ActiveSupport::TestCase

  test "#run sets success conditions on successful run" do
    primary = ActiveRecord::Base.connection
    Easymon::Base.establish_connection
    replica = Easymon::Base.connection

    check = Easymon::SplitActiveRecordCheck.new { [primary, replica] }

    results = check.check

    assert_equal("Primary: Up - Replica: Up", results[1])
    assert_equal(true, results[0])
  end

  test "#run sets failed conditions when replica is down" do
    primary = ActiveRecord::Base.connection
    Easymon::Base.establish_connection
    replica = Easymon::Base.connection

    replica.stubs(:active?).raises("boom")

    check = Easymon::SplitActiveRecordCheck.new { [primary, replica] }
    results = check.check

    assert_equal("Primary: Up - Replica: Down", results[1])
    assert_equal(false, results[0])
  end

  test "#run sets failed conditions when primary is down" do
    primary = ActiveRecord::Base.connection
    Easymon::Base.establish_connection
    replica = Easymon::Base.connection

    primary.stubs(:active?).raises("boom")

    check = Easymon::SplitActiveRecordCheck.new { [primary, replica] }
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
  class Base < ActiveRecord::Base
    def establish_connection(spec = nil)
      if spec
        super
      elsif config = Easymon.database_configuration
        super config
      end
    end

    def database_configuration
      env = "#{Rails.env}_replica"
      YAML.load_file(Rails.root.join('config/database.yml'))[env]
    end
  end
end
