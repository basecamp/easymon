if Rails.env.development?
  Easymon::Repository.add("redis", Easymon::RedisCheck.new("config/redis.yml"))
  Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
  Easymon::Repository.add("memcached", Easymon::MemcachedCheck.new(Rails.cache))
end