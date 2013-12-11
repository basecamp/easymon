if Rails.env.development?
  Easymon::Repository.add("redis", Easymon::RedisCheck.new(YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys))
  Easymon::Repository.add("database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
  Easymon::Repository.add("memcached", Easymon::MemcachedCheck.new(Rails.cache))
end