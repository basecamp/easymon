module Easymon
  class Engine < ::Rails::Engine
    # Rails Engines weren't isolated until v3.1
    if Gem::Version.new(Rails.version) >= Gem::Version.new("3.1")
      isolate_namespace Easymon
    end
  end
end
