module Easymon
  class SplitActiveRecordCheck
    attr_accessor :block
    attr_accessor :results

    # Here we pass a block so we get a fresh instance of ActiveRecord::Base or
    # whatever other class we might be using to make database connections
    #
    # For example, given the following other class:
    # module Easymon
    #   class Replica < ActiveRecord::Base
    #     establish_connection :"primary_replica"
    #   end
    # end
    #
    # We would check both it and ActiveRecord::Base like so:
    # check = Easymon::SplitActiveRecordCheck.new {
    #   [ActiveRecord::Base.connection, Easymon::Replica.connection]
    # }
    # Easymon::Repository.add("split-database", check)
    def initialize(&block)
      self.block = block
    end

    # Assumes only 2 connections
    def check
      connections = Array(@block.call)

      results = connections.map{|connection| database_up?(connection) }

      primary_status = results.first ? "Primary: Up" : "Primary: Down"
      replica_status = results.last ? "Replica: Up" : "Replica: Down"

      [(results.all? && results.count > 0), "#{primary_status} - #{replica_status}"]
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
