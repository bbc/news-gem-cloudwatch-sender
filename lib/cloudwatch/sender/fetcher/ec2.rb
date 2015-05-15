module Cloudwatch
  module Sender
    module Fetcher
      class EC2
        attr_reader :metric_prefix, :cloudwatch, :sender

        def initialize(cloudwatch, sender, metric_prefix)
          @cloudwatch = cloudwatch
          @sender = sender
          @metric_prefix = metric_prefix
        end

        START_TIME = 180

        def metrics(component_meta, metric)
          instances = Cloudwatch::Sender::EC2.new
          response = instances.list_instances(component_meta["ec2_component"], component_meta["metric_name"]).flatten
          ec2_metrics(response, component_meta, metric)
        end

        def ec2_metrics(instances, component_meta, metric)
          instances.each do |instance|
            resp = cloudwatch.get_metric_statistics(
              :namespace   => component_meta["namespace"],
              :metric_name => metric["name"],
              :dimensions  => [{ :name => "InstanceId", :value => instance }],
              :start_time  => Time.now - START_TIME,
              :end_time    => Time.now,
              :period      => 60,
              :statistics  => metric["statistics"],
              :unit        => metric["unit"]
            )
            name_metrics(resp, instance, component_meta["metric_name"], metric["statistics"])
          end
        end

        private

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
    end
  end
end
