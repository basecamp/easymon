module Easymon
  module Testing
    extend self

    def stub_check(name)
      Easymon.const_get("#{name.to_s.capitalize}Check").any_instance.stubs(:check)
    end

    def stub_service_success(name)
      stub_check(name).returns([true, "Up"])
    end

    def stub_service_failure(name)
      stub_check(name).returns([false, "Down"])
    end
  end
end
