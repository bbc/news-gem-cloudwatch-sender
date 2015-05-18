require "thor"
require "logger"
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

      desc "send_metrics [metrics_file] [key_id] [access_key] [region]", "Gets metrics from Cloudwatch and sends them to influx"
      def send_metrics(metrics_file, key_id, access_key, region)
        setup_aws(key_id, access_key, region)
        MetricDefinition.metric_type load_metrics(metrics_file)
      end

      desc "continuous [metrics_file] [key_id] [access_key] [region] [sleep time]", "Continuously sends metrics to Influx/Cloudwatch"
      def continuous(metrics_file, key_id, access_key, region, sleep_time = 60)
        logger = Logger.new(STDOUT)

        loop do
          begin
            send_metrics(metrics_file, key_id, access_key, region)
            sleep sleep_time.to_i
          rescue => e
            logger.debug("Unable to complete operation #{e}")
          end
        end
      end

      no_commands do
        def load_metrics(metrics_file)
          YAML.load(File.open(metrics_file))
        end

        def setup_aws(key_id, access_key, region)
          Aws.config.update(:region      => region,
                            :credentials => Aws::Credentials.new(key_id, access_key))
        end
      end
    end
  end
end
