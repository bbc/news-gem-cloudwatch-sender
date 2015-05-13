require "thor"
require 'cloudwatch/sender'
require 'cloudwatch/ec2'
require 'cloudwatch/ec2fetcher'
require 'cloudwatch/metric'
require 'cloudwatch/customfetcher'

class CloudwatchSender::CLI < Thor
  include Thor::Actions

  desc "send_metrics [metrics_file] [key_id] [access_key] [region]", "gets metrics from Cloudwatch and sends them to influx"
  def send_metrics(metrics_file, key_id, access_key, region)
    components = YAML.load(File.open(metrics_file))
    MetricDefinition.metric_type(components, key_id, access_key, region)
  end
end
