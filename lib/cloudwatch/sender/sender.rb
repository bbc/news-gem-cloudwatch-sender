require "logger"
require "aws-sdk"
require "json"
require "yaml"

module Cloudwatch
  module Sender
    class Base
      attr_accessor :influx_server, :influx_port

      def initialize(server, port)
        @influx_server = server
        @influx_port   = port
      end

      def send_tcp(contents)
        sock = TCPSocket.open(influx_server, influx_port)
        sock.print(contents)
      rescue StandardError => e
        @logger.debug("Error : #{e}")
      ensure
        sock.close
      end
    end
  end
end
