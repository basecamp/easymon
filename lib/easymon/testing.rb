module Easymon
  class Testing
    def self.stub_check(name)
      Easymon.const_get("#{name.to_s.capitalize}Check").any_instance.stubs(:check)
    end

    def self.stub_service_success(name)
      stub_check(name).returns([true, "Up"])
    end

    def self.stub_service_failure(name)
      stub_check(name).returns([false, "Down"])
    end
  end
end
