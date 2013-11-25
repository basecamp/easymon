if Rails.env.development?
  Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
  Easymon::Repository.add("redis", Easymon::RedisCheck.new(redis))
  Easymon::Repository.add("memcached", Easymon::MemcachedCheck.new(Rails.cache))
end