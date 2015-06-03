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

      class_option :provider, :desc => 'AWS security provider', :required => false
      class_option :access_key_id, :desc => 'AWS access_key_id', :required => false
      class_option :secret_access_key, :desc => 'AWS secret_key_id', :required => false
      class_option :region, :desc => 'AWS region', :required => false

      desc "send_metrics [metrics_file]", "Gets metrics from Cloudwatch and sends them to influx"
      def send_metrics(metrics_file, opts = {})
        setup_aws(options.merge(opts))
        MetricDefinition.metric_type load_metrics(metrics_file)
      end

      desc "continuous [metrics_file] [sleep time]", "Continuously sends metrics to Influx/Cloudwatch"
      def continuous(metrics_file, sleep_time = 60, opts = {})
        logger = Logger.new(STDOUT)

        loop do
          begin
            send_metrics(metrics_file, options.merge(opts))
            sleep sleep_time.to_i
          rescue RequiredArgumentMissingError, ArgumentError => e
            logger.error("Required argument invalid or missing '#{e}'")
            exit(1)
          rescue Aws::Errors::MissingCredentialsError => e
            logger.error("#{e}")
            exit(1)
          rescue => e
            logger.debug("Unable to complete operation #{e}")
          end
        end
      end

      no_commands do
        def load_metrics(metrics_file)
          YAML.load(File.open(metrics_file))
        end

        def setup_aws(options)
          credentials = nil
          if options['provider']
            case true
              when ['iam', 'instance_profile'].include?(options['provider'].downcase)
                credentials = Aws::InstanceProfileCredentials.new
              when (options['access_key_id'])
                credentials = Aws::Credentials.new(options['access_key_id'], options['secret_access_key'])
              else
               raise ArgumentError.new("'--provider' invalid argument '#{options['provider']}'")
            end
          else
            if (options['access_key_id'] || options['secret_access_key']) && ( ! options['access_key_id'] || !options['secret_access_key'])
              raise RequiredArgumentMissingError.new("'--access_key_id' and '--secret_access_key' required")
            end
            credentials = Aws::Credentials.new(options['access_key_id'], options['secret_access_key'])
          end
          Aws.config.update(:region => region = (options['region'] || ENV['AWS_REGION']), :credentials => credentials)
        end
      end
    end
  end
end
