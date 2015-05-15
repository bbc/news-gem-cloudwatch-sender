require "aws-sdk"

module Cloudwatch
  module Sender
    class EC2
      def initialize
        @ec2 = Aws::EC2::Client.new
      end

      def list_instances(key, value)
        list_instance_ids aws_resp(key, value)
      end

      private

      attr_reader :ec2

      def aws_resp(key, value)
        ec2.describe_instances(
          :filters => [
            {
              :name   => "tag-key",
              :values => [key]
            },
            {
              :name   => "tag-value",
              :values => [value]
            }
          ]
        )
      end

      def list_instance_ids(instances)
        instances.reservations.map do |reservations|
          reservations.instances.map(&:instance_id)
        end
      end
    end
  end
end
