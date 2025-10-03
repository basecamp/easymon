module Easymon
  class Repository
    attr_reader :repository

    def self.fetch(name)
      repository.fetch(name)
    rescue IndexError
      raise NoSuchCheck, "No check named '#{name}'"
    end

    def self.all
      Checklist.new repository
    end

    def self.names
      repository.keys
    end

    def self.add(name, check, is_critical = false)
      entry = { check: check, critical: is_critical ? true : false }
      repository[name] = entry
    end

    def self.remove(name)
      repository.delete(name)
    end

    def self.repository
      @repository ||= {}
    end

    def self.critical
      repository.map { |name, entry| name if entry[:critical] }.compact
    end
  end
end
