config = YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys
redis = Redis.new(config)