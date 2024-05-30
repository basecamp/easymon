module Easymon
  class ActiveRecordMysqlPrimaryDcCheck
    attr_accessor :klass
    attr_accessor :options

    def initialize(klass, options)
      self.klass = klass
      self.options = options
      @query = options[:query] || "SELECT @@report_host"

      raise "No datacenter given during initialization" unless options[:datacenter]
    end

    def check
      mysql_primary_dc = extract_dc
      check_status = mysql_primary_dc == options[:datacenter]
      message = "MySQL primary datacenter is: #{mysql_primary_dc}"

      [check_status, message]
    end

    private
    def retrieve_mysql_hostname
      klass.connection.execute(@query).to_enum.first.first
    rescue
      false
    end

    def extract_dc
      mysql_primary_hostname = retrieve_mysql_hostname

      # This probably means the lookup failed for whatever reason
      return nil unless mysql_primary_hostname

      # If we've been given a custom preprocessor, just use it directly
      return options[:preprocessor].call(mysql_primary_hostname) if options[:preprocessor]

      # Default path, we assume <node-hostname>.<datacenter>.<domain>
      # The goal is to split out the datacenter from here
      parts = mysql_primary_hostname.split(".")
      raise "Expected > 2 parts from: #{parts} (example: abcd-db-01.dc1.domain.com = 4 parts)" if parts.length < 3

      parts[1]
    end
  end
end
