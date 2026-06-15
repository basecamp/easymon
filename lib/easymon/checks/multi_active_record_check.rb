module Easymon
  class MultiActiveRecordCheck
    attr_accessor :block
    attr_accessor :query
    attr_accessor :results

    # Here we pass a block so we get a fresh instance of ActiveRecord::Base or
    # whatever other class we might be using to make database connections
    #
    # For example, given the following other class:
    # module Easymon
    #   class PrimaryReplica < ActiveRecord::Base
    #     establish_connection :"primary_replica"
    #   end
    #
    #   class OtherReplica < ActiveRecord::Base
    #     establish_connection :"other_replica"
    #   end
    # end
    #
    # We would check both it and ActiveRecord::Base like so:
    # check = Easymon::MultiActiveRecordCheck.new {
    #    {
    #      "Primary": ActiveRecord::Base.connection,
    #      "PrimaryReplica": Easymon::PrimaryReplica.connection
    #      "OtherReplica": Easymon::OtherReplica.connection
    #    }
    # }
    # Easymon::Repository.add("multi-database", check)
    #
    # Optionally, a health check query can be given instead of relying on
    # connection.active?. The query is run against each connection and must
    # return a single truthy/falsey value (e.g. 1/0 from MySQL):
    # check = Easymon::MultiActiveRecordCheck.new(query: "SELECT @@read_only") {
    #    { "Primary": ActiveRecord::Base.connection }
    # }
    #
    # A per-connection query can also be given by pairing the connection with
    # its query. It takes precedence over the default query: option above:
    # check = Easymon::MultiActiveRecordCheck.new {
    #    {
    #      "Primary": [ActiveRecord::Base.connection, "SELECT @@read_only"],
    #      "PrimaryReplica": [Easymon::PrimaryReplica.connection, "SELECT TIMESTAMPDIFF(MICROSECOND, MAX(ts), NOW(6)) / 1000000 < 1 FROM percona.heartbeat"],
    #      "OtherReplica": Easymon::OtherReplica.connection # plain connection.active?
    #    }
    # }

    def initialize(query: nil, &block)
      self.query = query
      self.block = block
    end

    def check
      connections = Hash(@block.call)

      results = connections.transform_values do |value|
        connection, connection_query = value.is_a?(Array) ? value : [ value, nil ]
        database_up?(connection, query: connection_query || query)
      end

      status = results.map { |db_name, result| "#{db_name}: #{result ? 'Up' : 'Down'}" }.join(" - ")

      [ (results.any? && results.values.all?), status ]
    end

    private
      def database_up?(connection, query: nil)
        connection.connect!
        if query
          ActiveModel::Type::Boolean.new.cast(connection.select_value(query)) || false
        else
          connection.active?
        end
      rescue
        false
      end
  end
end
