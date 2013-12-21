#Easymon

This gem extracts and modularizes the logic we had in our monitoring controllers
and were copying back and forth between applications.

Currently Rails 3+.


## Installation

Add to Gemfile and bundle!:

    gem 'easymon'
    bundle


##Usage
Ok, you'll need to add an initializer for this to do anything. In 
`config/initializers/easymon.rb`:

    Easymon::Repository.add("application-database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
This will register a check called "application-database" for use.

Next, we need to add the routes to your application. Depending on the rails version,
this is done one of two ways:

###Rails 2.3.x & 3.0
Add `Easymon.routes(map)` to your `config/routes.rb`.  This will put the Easymon
routes under `/up`.  If you want Easymon mounted somewhere other than `/up`, use
`Easymon.routes(map, "/monitoring")`.  That would put the Easymon paths under 
`/monitoring`.

###Rails 3.1+
Since we now have mountable engines, use the standard syntax, adding 
`mount Easymon::Engine => "/up"` to your `config/routes.rb`.


Now, you can run your entire checklist by visiting `/up`, or wherever you have
mounted the application.  If you want to just test the single check, go to 
`/up/application-database`, and only the check named `application-database` will
be run.

###Critical Checks
If you have several services that are critical to your app, and others that
are not, you can segregate those for health check purposes if you wish.  Assuming
your database and redis are critical, but memcached is not, again in
`config/initializers/easymon.rb`:

    Easymon::Repository.add(
      "application-database", 
      Easymon::ActiveRecordCheck.new(ActiveRecord::Base), 
      true
    )
    Easymon::Repository.add(
      "redis", 
      Easymon::RedisCheck.new(
        YAML.load_file(
          Rails.root.join("config/redis.yml")
        )[Rails.env].symbolize_keys
      ), 
      true
    )
    Easymon::Repository.add(
      "memcached", 
      Easymon::MemcachedCheck.new(Rails.cache)
    )
In addition to the main route `/up`, this will register four checks, individually
available at:
 * `/up/application-database`
 * `/up/redis`
 * `/up/memcached`
 * `/up/critical` - Runs both the application-database and redis checks.
 

##Included Checks

 * ActiveRecord
 * Redis
 * Memcached
 * Semaphore
 * Traffic Enabled
 * Split ActiveRecord
 * Http
 
###ActiveRecord
`Easymon::ActiveRecordCheck` is a basic check that uses ActiveRecord to check the
availability of your main database.  It's usually invoked as such:

    Easymon::ActiveRecordCheck.new(ActiveRecord::Base)

Internally, it compares `1 == klass.connection.select_value("SELECT 1=1").to_i`
where klass is whatever class you passed to the check.  Usually this will be 
ActiveRecord::Base, but feel free to go crazy.

###Redis
`Easymon::RedisCheck` will check the availability of a Redis server, given an
appropriate config hash.  Typically, we'll read the config off disk, but as long
as you get a valid config hash, this will work:

    Easymon::RedisCheck.new(YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys)

This is the most visually complex test to instantiate, but it's only because we're
loading the config from disk and getting the config block that matches the Rails.env
in one line.  As long as you pass a hash that can be used by Redis.new.

###Memcached
`Easymon::MemcachedCheck` is a basic check that will write and then read a key
from the cache.  It expects a cache instance to check, so it could be as easy as:

    Easymon::MemcachedCheck.new(Rails.cache)

###Semaphore
`Easymon::Semaphore` checks for the presence of a file on disk relative to the 
Rails.root of the current application.

    check = Easymon::SemaphoreCheck.new("config/redis.yml")
This is mainly a check that gets subclassed by the next check.

###Traffic Enabled
`Easymon::TrafficEnabledCheck` is fairly specific, but when we want a server to
accept traffic, we can place a file in the Rails.root, and the load balancers 
can use the result of this check to help decide whether or not to send traffic to
the node.

    Easymon::TrafficEnabledCheck.new("enable-traffic")

###Split ActiveRecord
`Easymon::SplitActiveRecordCheck` is the most complicated check, as it's not
something you can use out of the gate. Here we pass a block so we get a fresh 
instance of `ActiveRecord::Base` or whatever other class we might be using to make
a secondary database connection.

For example, given the following other class:

    module Easymon
      class Base < ActiveRecord::Base
        def establish_connection(spec = nil)
          if spec
            super
          elsif config = Easymon.database_configuration
            super config
          end
        end
        def database_configuration
          env = "#{Rails.env}_slave"
          config = YAML.load_file(Rails.root.join('config/database.yml'))[env]
        end
      end
    end

We would check both it and `ActiveRecord::Base` like so (two lines for readability):

    check = Easymon::SplitActiveRecordCheck.new {
      [ActiveRecord::Base.connection, Easymon::Base.connection] 
    }
    Easymon::Repository.add("split-database", check)

###Http
`Easymon::HttpCheck` will check the return status of a HEAD request to a URL. Great
for checking service endpoint availability! The following will make a request to 
port 9200 on localhost, which is where you might have Elasticsearch running:

    Easymon::HttpCheck.new("http://localhost:9200")

Typically, we'll read an elasticsearch config off disk, and use the URL like so:

    config = YAML.load_file(Rails.root.join("config/elasticsearch.yml"))[Rails.env].symbolize_keys
    Easymon::HttpCheck.new(config[:url])