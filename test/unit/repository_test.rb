require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  
  test "we can add a check to the repository" do
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
    check = Easymon::Repository.fetch("database")
    
    assert_equal 1, Easymon::Repository.repository.size, Easymon::Repository.repository.inspect
    assert check.instance_of? Easymon::ActiveRecordCheck
  end
  
  test "we can remove a check from the repository" do
    Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
    assert_equal 1, Easymon::Repository.repository.size
    
    Easymon::Repository.remove("database")
    exception = assert_raises Easymon::Repository::NoSuchCheck do
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
end