module Easymon
  class Repository
    def self.fetch(name)
      repository.fetch(name)
    rescue KeyError
      raise NoSuchCheck, "No check named '#{name}'"
    end
    
    def self.all
      Checklist.new repository
    end
    
    def self.add(name, check)
      check.name = name
      repository[name] = check
    end
    
    def self.remove(name)
      repository.delete(name)
    end
    
    def self.repository
      @repository ||= {}
    end
    
    NoSuchCheck = Class.new(StandardError)
  end
end