require "easymon/engine"
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
end
