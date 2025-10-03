module Easymon
  class MultiActiveRecordCheck
    attr_accessor :block
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

    def initialize(&block)
      self.block = block
    end

    def check
      connections = Hash(@block.call)

      results = connections.transform_values { |connection| database_up?(connection) }

      status = results.map { |db_name, result| "#{db_name}: #{result ? 'Up' : 'Down'}" }.join(" - ")

      [ (results.any? && results.values.all?), status ]
    end

    private
      def database_up?(connection)
        connection.connect!
        connection.active?
      rescue
        false
      end
  end
end
