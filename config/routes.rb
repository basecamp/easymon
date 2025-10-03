# use `mount Easymon::Engine => "/up"` in the host application routes.rb
if Gem::Version.new(Rails.version) >= Gem::Version.new("3.1")
  Easymon::Engine.routes.draw do
    Easymon.routes(self)
  end
end
