module Cloudwatch
  module Sender
    module Fetcher
      class Custom
        attr_reader :metric_prefix, :cloudwatch, :sender

        def initialize(cloudwatch, sender, metric_prefix)
          @cloudwatch = cloudwatch
          @sender = sender
          @metric_prefix = metric_prefix
        end

        START_TIME = 180

        def metrics(component_meta, metric)
          resp = cloudwatch.get_metric_statistics(
            :namespace   => component_meta["namespace"],
            :metric_name => metric["name"],
            :start_time  => Time.now - START_TIME,
            :end_time    => Time.now,
            :period      => 60,
            :statistics  => metric["statistics"],
            :unit        => metric["unit"]
          )
          name = component_meta["namespace"].downcase
          name_metrics(resp, name, metric["statistics"])
        end

        private

        def name_metrics(resp, name, statistics)
          resp.data["datapoints"].each do |data|
            time = data["timestamp"].to_i
            check_statistics(name, resp.data["label"], statistics, time, data)
          end
        end

        def check_statistics(name, label, statistics, time, data)
          statistics.each do |stat|
            sender.send_tcp("#{metric_prefix}.#{name}.#{label.downcase}.#{stat.downcase}" " " "#{data[stat.downcase]}" " "  "#{time}")
          end
        end
      end
    end
  end
end
