require "thor"
require "cloudwatch/sender/sender"
require "cloudwatch/sender/ec2"
require "cloudwatch/sender/metric_definition"
require "cloudwatch/sender/fetcher/base"
require "cloudwatch/sender/fetcher/ec2"
require "cloudwatch/sender/fetcher/sqs"
require "cloudwatch/sender/fetcher/custom"

module Cloudwatch
  module Sender
    class CLI < Thor
      include Thor::Actions

      desc "send_metrics [metrics_file] [key_id] [access_key] [region]", "gets metrics from Cloudwatch and sends them to influx"
      def send_metrics(metrics_file, key_id, access_key, region)
        setup_aws(key_id, access_key, region)
        components = load_metrics(metrics_file)
        MetricDefinition.metric_type(components)
      end

      no_commands do
        def load_metrics(metrics_file)
          YAML.load(File.open(metrics_file))
        end

        def setup_aws(key_id, access_key, region)
          Aws.config.update(region: region,
                            credentials: Aws::Credentials.new(key_id, access_key))
        end
      end
    end
  end
end
