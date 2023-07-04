require 'benchmark'

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
        check_result = []
        timing = Benchmark.realtime { check_result = check[:check].check }
        hash[name] = Easymon::Result.new(check[:check].class.name.demodulize, check_result, timing, check[:critical])
        hash
      end
      [self.success?, self.to_s]
    end

    def timing
      results.values.map{|r| r.timing}.inject(0, :+)
    end

    def to_text
      to_s
    end

    def to_s
      results.map{|name, result| "#{name}: #{result.to_s}"}.join("\n") +
      "\n - Total Time - " + Easymon.timing_to_ms(self.timing) + "ms"
    end

    def to_hash
      combined = {:timing => Easymon.timing_to_ms(timing)}
      results.each do |name, result|
        combined[name] = result.to_hash
      end
      combined
    end

    def to_prom
      output = ""

      # Status Loop
      output << <<~HELP
        # HELP easymon_check_up Target up
        # TYPE easymon_check_up gauge)
        HELP
      results.each do |name, result|
        labels = {check: name, type: result.type}
        labels[:critical] = "1" if result.is_critical?
        up = result.success? ? 1 : 0
        output << "easymon_check_up{#{labels.map{|k,v| k.to_s+'='+v}.join(",")}} #{up}\n"
      end

      # Timing Loop
      output << <<~HELP
        # HELP easymon_check_duration_seconds easymon check execution duration in seconds
        # TYPE easymon_check_duration_seconds gauge
      HELP
      results.each do |name, result|
        labels = {check: name, type: result.type}
        labels[:critical] = "1" if result.is_critical?
        output << "easymon_check_duration_seconds{#{labels.map{|k,v| k.to_s+'='+v}.join(",")}} #{'%f' % result.timing}\n"
      end

      output
    end

    def as_json(*args)
      to_hash
    end

    def success?
      return false if results.empty?
      results.values.all?(&:success?)
    end

    def response_status
      success? ? :ok : :service_unavailable
    end

    # The following method could be implemented as a def_delegator by
    # extending Forwardable, but since we want to catch IndexError and
    # raise Easymon::NoSuchCheck, we'll be explicit here.
    #
    def fetch(name)
      items.fetch(name)
    rescue IndexError
      raise NoSuchCheck, "No check named '#{name}'"
    end
  end
end
