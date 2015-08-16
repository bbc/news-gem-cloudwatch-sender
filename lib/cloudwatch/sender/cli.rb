require "thor"
require "json"
require "yaml"
require "logger"
require "openssl"
require "influxdb"
require "cloudwatch/sender/base"
require "cloudwatch/sender/ec2"
require "cloudwatch/sender/credentials"
require "cloudwatch/sender/metric_definition"
require "cloudwatch/sender/fetcher/base"
require "cloudwatch/sender/fetcher/ec2"
require "cloudwatch/sender/fetcher/sqs"
require "cloudwatch/sender/fetcher/custom"

module Cloudwatch
  module Sender
    class CLI < Thor
      include Thor::Actions

      class_option :provider, :desc => "AWS security provider", :required => false, :enum => %w(iam instance_profile)
      class_option :access_key_id, :desc => "AWS access_key_id", :required => false
      class_option :secret_access_key, :desc => "AWS secret_key_id", :required => false
      class_option :region, :desc => "AWS region", :required => false

      desc "send_metrics [metrics_file]", "Gets metrics from Cloudwatch and sends them to influx"
      def send_metrics(metrics_file, opts = {})
        setup_aws(options.merge(opts), opts["provider"])
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

        def setup_aws(options, provider)
          SetupAwsCredentials.send("#{validate_provider(provider)}".to_sym, options)
        end

        def validate_provider(provider)
          return "access_key_id" if provider.nil?
          if %w(iam instance_profile).include? provider.downcase
            provider.downcase
          else
            fail ArgumentError.new("'--provider' invalid argument '#{options['provider']}'")
          end
        end

        def send_metrics_ruby(hash, opts = {})
          setup_aws(options.merge(opts), opts["provider"])
          MetricDefinition.metric_type hash
        end
      end
    end
  end
end
