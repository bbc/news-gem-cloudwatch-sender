require 'aws-sdk'
require 'cloudwatch/sender'
require 'cloudwatch/ec2'

class EC2Fetcher
  attr_reader :components, :metric_prefix, :cloudwatch, :sender, :key_id, :access_key, :region

  def initialize(components, key_id, access_key, region)
    @components = components
    @key_id = key_id
    @access_key = access_key
    @region = region
    @metric_prefix = components['metric_prefix']
    @sender = CloudwatchSender::Base.new(components["influx_host"], components["influx_port"])

    @cloudwatch = Aws::CloudWatch::Client.new(
      :region            => region,
      :access_key_id     => key_id,
      :secret_access_key => access_key
    )
  end

  def retrieve
    components['metric_types'].each do |component_meta|
      component_meta["metrics"].each do |metric|
        ec2_getter(component_meta, metric)
      end
    end
  end

  private

  def ec2_getter(component_meta, metric)
    instances = EC2.new(key_id, access_key, region)
    response = instances.list_instances(component_meta["ec2_component"], component_meta['metric_name']).flatten
    ec2_metrics(response, component_meta, metric)
  end

  def ec2_metrics(instances, component_meta, metric)
    instances.each do |instance|
      resp = cloudwatch.get_metric_statistics(
        :namespace   => component_meta['namespace'],
        :metric_name => metric['name'],
        :dimensions  => [{ :name => "InstanceId", :value => instance }],
        :start_time  => Time.now - 300,
        :end_time    => Time.now,
        :period      => 60,
        :statistics  => metric['statistics'],
        :unit        => metric['unit']
        )
      name_metrics(resp, instance, component_meta['metric_name'], metric['statistics'])
    end
  end

  def name_metrics(resp, instance, name, statistics)
    resp.data["datapoints"].each do |data|
      time = data["timestamp"].to_i
      check_statistics(instance, name, resp.data["label"], statistics, time, data)
    end
  end

  def check_statistics(instanceid, name, label, statistics, time, data)
    statistics.each do |stat|
      sender.send_tcp("#{metric_prefix}.#{name}.#{instanceid}.#{label.downcase}.#{stat}" " " "#{data[stat.downcase]}" " "  "#{time}")
    end
  end
end
