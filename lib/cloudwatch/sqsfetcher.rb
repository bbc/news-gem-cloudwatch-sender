class SQSFetcher
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
        sqs_metrics(component_meta, metric)
      end
    end
  end

  def sqs_metrics(component_meta, metric)
    resp = cloudwatch.get_metric_statistics(
      :namespace   => component_meta['namespace'],
      :metric_name => metric['name'],
      :dimensions  => [{ :name => "QueueName", :value => component_meta['queue_name'] }],
      :start_time  => Time.now - 180,
      :end_time    => Time.now,
      :period      => 60,
      :statistics  => metric['statistics'],
      :unit        => metric['unit']
      )
    name = component_meta['namespace'].downcase
    name_metrics(resp, name, metric['statistics'], component_meta['queue_name'])
  end

  def name_metrics(resp, name, statistics, queue_name)
    resp.data["datapoints"].each do |data|
      time = data["timestamp"].to_i
      check_statistics(name, resp.data["label"], statistics, time, data, queue_name)
    end
  end

  def check_statistics(name, label, statistics, time, data, queue_name)
    statistics.each do |stat|
      p ("#{metric_prefix}.#{name}.#{queue_name}.#{label.downcase}.#{stat.downcase}" " " "#{data[stat.downcase]}" " "  "#{time}")
      sender.send_tcp("#{metric_prefix}.#{name}.#{queue_name}.#{label.downcase}.#{stat.downcase}" " " "#{data[stat.downcase]}" " "  "#{time}")
    end
  end
end
