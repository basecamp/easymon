module Easymon
  class Checklist
    attr_accessor :items
    
    def initialize(items={})
      self.items = items
    end
    
    def run
      checks.each(&:run)
    end
    
    def checks
      items.values
    end
    
    def to_text
      to_s
    end
    
    def to_s
      checks.map(&:to_s).join("\n")
    end
    
    def to_json(*args)
      combined = []
      checks.each do |check|
        combined << check.to_hash
      end
      combined.to_json
    end
    
    def success?
      checks.all?(&:success?)
    end
    
    def critical_success?
      checks.select(&:critical).all?(&:success?)
    end
    
    def has_critical?
      checks.select(&:critical).size > 0
    end
    
  end
end