$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "easymon/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "easymon"
  s.version     = Easymon::VERSION
  s.authors     = ["Nathan Anderson"]
  s.email       = ["andnat@gmail.com"]
  s.homepage    = "http://github.com/37signals/easymon"
  s.summary     = "Simple availability checks for your rails 3+ app"
  s.description = "Enables your monitoring infrastructure to easily query the
                   status of your app server's health.  Provides routes under
                   /up."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rest-client"
  s.add_dependency "redis"

  s.add_development_dependency "rails"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "mocha"
  s.add_development_dependency "dalli"
  
end
