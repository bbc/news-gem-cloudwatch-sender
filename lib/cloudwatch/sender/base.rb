module Cloudwatch
  module Sender
    class Base
      attr_reader :influx_server, :influx_port

      def initialize(server, port)
        @influx_server = server
        @influx_port   = port
      end

      def send_tcp(contents)
        p contents
        send = API.new("#{influx_server}:#{influx_port}", ENV["BBC_COSMOS_TOOLS_CERT"])
        send.post(contents)
      end
    end
  end
end
