module Easymon
  class Checklist
    extend Forwardable
    def_delegators :@items, :size, :include?, :empty?
    
    attr_accessor :items
    attr_accessor :results
    
    def initialize(items={})
      self.items = items
      self.results = {}
    end
    
    def check
      self.results = items.inject({}) do |hash, (name, check)|
        hash[name] = Easymon::Result.new(check.check)
        hash
      end
      [self.success?, self.to_s]
    end
    
    def to_text
      to_s
    end
    
    def to_s
      self.results.map{|name, result| "#{name}: #{result.to_s}"}.join("\n")
    end
    
    def to_json(*args)
      combined = []
      self.results.each do |name, result|
        combined << result.to_hash.merge({"name" => name})
      end
      combined.to_json
    end
    
    def success?
      return false if results.empty?
      results.values.all?(&:success?)
    end
    
    def response_status
      success? ? :ok : :service_unavailable
    end
    
    # The following method could be implemented as a def_delegator by 
    # extending Forwardable, but since we want to catch KeyError and
    # raise Easymon::NoSuchCheck, we'll be explicit here.
    # 
    def fetch(name)
      items.fetch(name)
    rescue KeyError
      raise NoSuchCheck, "No check named '#{name}'"
    end
  end
end