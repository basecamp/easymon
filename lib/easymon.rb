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
require "easymon/testing"

module Easymon
  NoSuchCheck = Class.new(StandardError)

  def self.rails_version
    Gem::Version.new(Rails.version)
  end

  def self.rails2?
    Easymon.rails_version.between?(Gem::Version.new("2.3"), Gem::Version.new("3.0"))
  end

  def self.rails30?
    Easymon.rails_version.between?(Gem::Version.new("3.0"), Gem::Version.new("3.1"))
  end

  def self.mountable_engine?
    Easymon.rails_version > Gem::Version.new("3.1")
  end

  def self.routes(mapper, path = "/up")
    if Easymon.rails2?
      # Rails 2.3.x (anything less than 3, really)
      $:.unshift File.expand_path(File.join(
        File.dirname(__FILE__),
        "..","app","controllers"))
      require 'easymon/checks_controller'

      mapper.instance_eval do
        connect "#{path}.:format", :controller => "easymon/checks", :action => "index"
        connect "#{path}/:check.:format", :controller => "easymon/checks", :action => "show"
      end
    elsif Easymon.rails30?
      # Greater than 3.0, but less than 3.1
      mapper.instance_eval do
        get "#{path}(.:format)" => 'easymon/checks#index'
        get "#{path}/:check" => 'easymon/checks#show'
      end
    elsif Easymon.mountable_engine?
      # Rails 3.1+
      mapper.instance_eval do
        get "/(.:format)", :to => "checks#index"
        root :to => "checks#index"
        get "/:check", :to => "checks#show"
      end
    end
  end
  
  def self.timing_to_ms(timing = 0)
    sprintf("%.3f", (timing * 1000))
  end
end
