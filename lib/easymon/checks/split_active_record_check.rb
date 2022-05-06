module Easymon
  class SplitActiveRecordCheck
    attr_accessor :block
    attr_accessor :results

    # Here we pass a block so we get a fresh instance of ActiveRecord::Base or
    # whatever other class we might be using to make database connections
    #
    # For example, given the following other class:
    # module Easymon
    #   class Base < ActiveRecord::Base
    #     def establish_connection(spec = nil)
    #       if spec
    #         super
    #       elsif config = Easymon.database_configuration
    #         super config
    #       end
    #     end
    #
    #     def database_configuration
    #       env = "#{Rails.env}_replica"
    #       config = YAML.load_file(Rails.root.join('config/database.yml'))[env]
    #     end
    #   end
    # end
    #
    # We would check both it and ActiveRecord::Base like so:
    # check = Easymon::SplitActiveRecordCheck.new {
    #   [ActiveRecord::Base.connection, Easymon::Base.connection] 
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
        connection.active?
      rescue
        false
      end
  end
end
