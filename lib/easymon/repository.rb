module Easymon
  class Repository
    attr_reader :repository
    attr_reader :critical
    
    def self.fetch(name)
      if repository.include?(name)
        return repository.fetch(name)
      else
        critical.fetch(name)
      end
    rescue IndexError
      raise NoSuchCheck, "No check named '#{name}'"
    end
    
    def self.all
      Checklist.new repository
    end
    
    def self.names
      repository.keys + critical.keys
    end
    
    def self.add(name, check, is_critical=false)
      if is_critical
        critical[name] = check
        repository["critical"] = Checklist.new critical
      else
        repository[name] = check
      end
    end
    
    def self.remove(name)
      repository.delete(name)
      critical.delete(name)
    end
    
    def self.repository
      @repository ||= {}
    end
    
    def self.critical
      @critical ||= {}
    end
  end
end