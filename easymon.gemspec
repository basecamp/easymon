$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "easymon/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "easymon"
  s.version     = Easymon::VERSION
  s.authors     = ["Nathan Anderson"]
  s.email       = ["nathan@basecamp.com"]
  s.homepage    = "https://github.com/basecamp/easymon"
  s.summary     = "Simple availability checks for your rails app"
  s.description = "Enables your monitoring infrastructure to easily query the
                   status of your app server's health.  Provides routes under
                   /up."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rest-client"
  s.add_dependency "redis"

  s.add_development_dependency "rails", ['>= 3.0', '>= 4.0', '>= 2.3.18']
  s.add_development_dependency "mysql2", "~> 0.3"
  s.add_development_dependency "mocha", "~> 1.1"
  s.add_development_dependency "dalli", "~> 2.7"
end
