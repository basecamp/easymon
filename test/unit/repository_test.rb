require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

  test "we can add a check to the repository" do
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
    check = Easymon::Repository.fetch("database")

    assert_equal 1, Easymon::Repository.repository.size, Easymon::Repository.repository.inspect
    assert check[:check].instance_of? Easymon::ActiveRecordCheck
  end

  test "we can remove a check from the repository" do
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
    assert_equal 1, Easymon::Repository.repository.size

    Easymon::Repository.remove("database")
    exception = assert_raises Easymon::NoSuchCheck do
      Easymon::Repository.fetch("database")
    end

    assert_equal "No check named 'database'", exception.message
    assert_equal 0, Easymon::Repository.repository.size
  end

  test "returns a checklist when asked" do
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
    checklist = Easymon::Repository.all

    assert checklist.instance_of? Easymon::Checklist
  end

  test "adds checks marked critical to the critical checklist" do
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base), :critical)

    assert Easymon::Repository.critical.include?("database")
  end

  test "fetches a check by name" do
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
    check = Easymon::Repository.fetch("database")

    assert check[:check].instance_of? Easymon::ActiveRecordCheck
  end

  test "fetches a critical check by name" do
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base), :critical)
    check = Easymon::Repository.fetch("database")

    assert check[:check].instance_of? Easymon::ActiveRecordCheck
  end
end