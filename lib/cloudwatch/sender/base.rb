require "json"
require "yaml"

module Cloudwatch
  module Sender
    class Base
      def initialize(server, port)
        @influx_server = server
        @influx_port   = port
      end

      def send_tcp(contents)
        sock = TCPSocket.open(influx_server, influx_port)
        sock.print contents
      rescue StandardError => e
        logger.debug "Error: #{e}"
      ensure
        sock.close
      end

      protected

      attr_reader :influx_server, :influx_port
    end
  end
end
