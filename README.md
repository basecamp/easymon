# Easymon

Easymon helps you monitor your application's availability.  It provides a simple
way to test the availability of resources your application needs, like the
application database, a memcached connection, or a redis instance.  These test
results can be used by a load balancer to determine the general health and
viability of the node your application is running on.

It's packaged up as a rails engine for 3.1 and greater, and a plugin for 2.3 -
3.0.

## History

This gem extracts and modularizes the logic we had in our monitoring controllers
and were copying back and forth between applications.

## Installation

Add to Gemfile and bundle!:

````ruby
gem 'easymon'
````

## Usage
To get started, you'll need to add an initializer for this to do anything.
In `config/initializers/easymon.rb`:

````ruby
Easymon::Repository.add("application-database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base))
````

This will register a check called `application-database` for use.

Next, we need to add the routes to your application. Depending on the rails
version, this is done one of two ways:

### Rails 2.3.x & 3.0
Add `Easymon.routes(map)` to your `config/routes.rb`.  This will put the Easymon
routes under `/up`.  If you want Easymon mounted somewhere other than `/up`, use
`Easymon.routes(map, "/monitoring")`.  That would put the Easymon paths under
`/monitoring`.  For Rails 3.0, the default routes file does not provide `map`,
so use `Easymon.routes(self)` instead.

### Rails 3.1+
Rails 3.1+ gives us mountable engines, so use the standard syntax, adding
`mount Easymon::Engine => "/up"` to your `config/routes.rb`.


Now, you can run your entire checklist by visiting `/up`, or wherever you have
mounted the application.  If you want to just test the single check, go to
`/up/application-database`, and only the check named `application-database` will
be run.

### Critical Checks
If you have several services that are critical to your app, and others that
are not, you can segregate those for health check purposes if you wish.
Assuming your database and redis are critical, but memcached is not, again in
`config/initializers/easymon.rb`:

````ruby
Easymon::Repository.add(
  "application-database",
  Easymon::ActiveRecordCheck.new(ActiveRecord::Base),
  :critical
)
Easymon::Repository.add(
  "redis",
  Easymon::RedisCheck.new(
    YAML.load_file(
      Rails.root.join("config/redis.yml")
    )[Rails.env].symbolize_keys
  ),
  :critical
)
Easymon::Repository.add(
  "memcached",
  Easymon::MemcachedCheck.new(Rails.cache)
)
````

In addition to the main route `/up`, this will register four checks,
individually available at:

 * `/up/application-database`
 * `/up/redis`
 * `/up/memcached`
 * `/up/critical` - Runs both the application-database and redis checks.

## Security

You might not want to have this data available to everyone who hits your site,
as it can expose both timing data and, depending on your check names, various
bits of your infrastructure.  You can tell Easymon what addresses, headers,
or whatever defines an authorized request by providing a block to
`Easymon.authorize_with` that will be called with the current request object:

```ruby
Easymon.authorize_with = Proc.new { |request| request.remote_ip == '192.168.1.1'}
# Or
Easymon.authorize_with = Proc.new { |request|
  request.headers["X-Forwarded-For"].nil?
}
```

This will get run on each request, so keep it simple. (Actually, that's a good
rule of thumb for any checks you write, too.  Remember, these are all in your
main app request pipeline!)

## Checks

A check can be any ruby code that responds_to? a #check method that returns a
two element array. The first element is the result of executing the check and
should be true or false. The second element is the message describing what's
going on.  The array would look something like this: `[true, "Up"]` in the
case of a successful check or `[false, "Timeout"]` in the case of a failed
check.

### Included Checks

 * ActiveRecord
 * Redis
 * Memcached
 * Semaphore
 * Traffic Enabled
 * Split ActiveRecord
 * Http

### ActiveRecord
`Easymon::ActiveRecordCheck` is a basic check that uses ActiveRecord to check
the availability of your main database.  It's usually invoked as such:

````ruby
Easymon::ActiveRecordCheck.new(ActiveRecord::Base)
````

Internally, it checks `klass.connection.active?` where klass is whatever class
you passed to the check.  Usually this will be ActiveRecord::Base, but feel free
to go crazy.

### Redis
`Easymon::RedisCheck` will check the availability of a Redis server, given an
appropriate config hash.  Typically, we'll read the config off disk, but as long
as you get a valid config hash, this will work:

````ruby
Easymon::RedisCheck.new(
  YAML.load_file(Rails.root.join("config/redis.yml"))[Rails.env].symbolize_keys
)
````

This is the most visually complex test to instantiate, but it's only because
we're loading the config from disk and getting the config block that matches
the Rails.env in one line.  As long as you pass a hash that can be used by
Redis.new, it doesn't care where the config comes from.

### Memcached
`Easymon::MemcachedCheck` is a basic check that will write and then read a key
from the cache.  It expects a cache instance to check, so it could be as easy
as:

````ruby
Easymon::MemcachedCheck.new(Rails.cache)
````

### Semaphore
`Easymon::Semaphore` checks for the presence of a file on disk relative to the
Rails.root of the current application.

````ruby
check = Easymon::SemaphoreCheck.new("config/redis.yml")
````

This is mainly a check that gets subclassed by the next check.

### Traffic Enabled
`Easymon::TrafficEnabledCheck` is fairly specific, but when we want a server to
accept traffic, we can place a file in the Rails.root, and the load balancers
can use the result of this check to help decide whether or not to send traffic
to the node.

````ruby
Easymon::TrafficEnabledCheck.new("enable-traffic")
````
This is a subclass of the Semaphore check mentioned above.

### Split ActiveRecord
`Easymon::SplitActiveRecordCheck` is the most complicated check, as it's not
something you can use out of the gate. Here we pass a block so we get a fresh
instance of `ActiveRecord::Base` or whatever other class we might be using to
make a secondary database connection.

For example, given the following other class:

````ruby
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
````

We would check both it and `ActiveRecord::Base` like so:

````ruby
check = Easymon::SplitActiveRecordCheck.new {
  [ActiveRecord::Base.connection, Easymon::Base.connection]
}
Easymon::Repository.add("split-database", check)
````

### Http
`Easymon::HttpCheck` will check the return status of a HEAD request to a URL.
Great for checking service endpoint availability! The following will make a
request to port 9200 on localhost, which is where you might have Elasticsearch
running:

````ruby
Easymon::HttpCheck.new("http://localhost:9200")
````

Typically, we'll read an elasticsearch config off disk, and use the URL like so:

````ruby
config = YAML.load_file(Rails.root.join("config/elasticsearch.yml"))[Rails.env].symbolize_keys
Easymon::HttpCheck.new(config[:url])
````

## Testing

To run the tests, you need MySQL server installed and running, and accepting connections
on localhost:3306 for the `root` user with a blank password, as configured in
[database.yml](./test/dummy/config/database.yml).

Create the MySQL test databases by running:

````
bundle exec rake db:create
````

To run tests on PostgreSQL, you need the server installed and running, and accepting
connections on localhost:5432 for the `dummy` user.  You can create the dummy user
with the following command in `psql`:

````sql
CREATE USER dummy WITH PASSWORD 'dummy';
````

Then run the tests with:

````
bundle exec rake test
````

## How to contribute

Here's the most direct way to get your work merged into the project:

1. Fork the project
2. Clone down your fork
3. Create a feature branch
4. Add your feature + tests
5. Document new features in the README
6. Make sure everything still passes by running the tests
7. If necessary, rebase your commits into logical chunks, without errors
8. Push the branch up
9. Send a pull request for your branch

If you're going to make a major change ask first to make sure it's in line with
the project goals.

## To Do

See the issues page. :smile:

## Authors

* [Nathan Anderson](mailto:andnat@gmail.com)

## License
See [LICENSE](LICENSE)
