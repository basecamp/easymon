if Gem::Version.new(Rails.version) >= Gem::Version.new("3.0")
  require "easymon/engine"
end
require "easymon/checklist"
require "easymon/repository"
require "easymon/result"

require "easymon/checks/active_record_check"
require "easymon/checks/split_active_record_check"
require "easymon/checks/redis_check"
require "easymon/checks/memcached_check"
require "easymon/checks/semaphore_check"
require "easymon/checks/traffic_enabled_check"
require "easymon/checks/http_check"

module Easymon
  NoSuchCheck = Class.new(StandardError)
  
  def self.routes(mapper, path = "/up")
    case 
    when Gem::Version.new(Rails.version) < Gem::Version.new("3.0")
      # Rails 2.3.x (anything less than 3, really)
      mapper.instance_eval do
        connect "#{path}", :controller => "easymon/checks", :action => "index"
        connect "#{path}/:check", :controller => "easymon/checks", :action => "show"
      end
    when Gem::Version.new(Rails.version) < Gem::Version.new("3.1")
      # Greater than 3.0, but less than 3.1
      mapper.instance_eval do
        get "#{path}", :to => "easymon/checks#index"
        get "#{path}/:check", :to => "easymon/checks#show"
      end
    when Gem::Version.new(Rails.version) >= Gem::Version.new("3.1")
      # Rails 3.1+
      mapper.instance_eval do
        get "/", :to => "checks#index"
        get "/:check", :to => "checks#show"
      end
    end
  end
end
