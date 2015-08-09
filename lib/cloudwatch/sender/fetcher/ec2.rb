module Cloudwatch
  module Sender
    module Fetcher
      class EC2
        def initialize(cloudwatch, sender)
          @cloudwatch = cloudwatch
          @sender = sender
        end

        def metrics(component_meta, metric)
          ec2_metrics(instance_list(component_meta), component_meta, metric)
        end

        private

        attr_reader :cloudwatch, :sender

        START_TIME = 1800

        def ec2_metrics(instance_list, component_meta, metric)
          instance_list.each do |instance|
            metric_data = aws_metric_meta(component_meta, metric, instance)
            resp = cloudwatch.get_metric_statistics metric_data
            name_metrics(resp, instance, component_meta["ec2_tag_value"], metric["statistics"])
          end
        end

        def aws_metric_meta(component_meta, metric, instance)
          {
            :namespace   => component_meta["namespace"],
            :metric_name => metric["name"],
            :dimensions  => [{ :name => "InstanceId", :value => instance }],
            :start_time  => Time.now - START_TIME,
            :end_time    => Time.now,
            :period      => 60,
            :statistics  => metric["statistics"],
            :unit        => metric["unit"]
          }
        end

        def ec2
          Cloudwatch::Sender::EC2.new
        end

        def instance_list(component_meta)
          ec2.list_instances(
            component_meta["ec2_tag_key"], component_meta["ec2_tag_value"]
          ).flatten
        end

        def name_metrics(resp, instance, name, statistics)
          resp.data["datapoints"].each do |data|
            check_statistics(instance, name, resp.data["label"], statistics, metric_time(data), data)
          end
        end

        def metric_time(data)
          data["timestamp"].to_i
        end

        def check_statistics(instanceid, name, label, statistics, time, data)
          statistics.each do |stat|
            data = {
              :tags      => { name.tr("^A-Za-z0-9", "") => label.downcase, "instance" => instanceid.tr("-", "") },
              :timestamp => time,
              :values    => { :value => data[stat.downcase] }
            }

            sender.write_data(data)
          end
        end
      end
    end
  end
end
