module Cloudwatch
  module Sender
    class Base
      attr_reader :influxdb, :metric_prefix

      def initialize(options, metric_prefix)
        @metric_prefix = metric_prefix
        @influxdb = InfluxDB::Client.new options["influx_database"] || "graphite",
          :username    => options["influx_username"],
          :password    => options["influx_password"],
          :use_ssl     => options["influx_ssl"] || false,
          :verify_ssl  => options["influx_verify_ssl"] || false,
          :ssl_ca_cert => options["influx_ssl_ca_cert"] || false,
          :host        => options["influx_host"] || false
      end

      def write_data(data)
        influxdb.write_point(metric_prefix, data)
      end
    end
  end
end
