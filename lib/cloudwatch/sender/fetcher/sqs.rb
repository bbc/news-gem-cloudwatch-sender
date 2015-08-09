module Cloudwatch
  module Sender
    module Fetcher
      class SQS
        attr_reader :cloudwatch, :sender

        def initialize(cloudwatch, sender)
          @cloudwatch = cloudwatch
          @sender = sender
        end

        START_TIME = 1200

        def metrics(component_meta, metric)
          resp = cloudwatch.get_metric_statistics(
            :namespace   => component_meta["namespace"],
            :metric_name => metric["name"],
            :dimensions  => [{ :name  => "QueueName",
                               :value => component_meta["queue_name"] }],
            :start_time  => Time.now - START_TIME,
            :end_time    => Time.now,
            :period      => 60,
            :statistics  => metric["statistics"],
            :unit        => metric["unit"]
          )
          name = component_meta["namespace"].downcase
          name_metrics(resp, name, metric["statistics"], component_meta["queue_name"])
        end

        private

        def name_metrics(resp, name, statistics, queue_name)
          resp.data["datapoints"].each do |data|
            time = data["timestamp"].to_i
            check_statistics(name, resp.data["label"], statistics, time, data, queue_name)
          end
        end

        def check_statistics(name, label, statistics, time, data, queue_name)
          statistics.each do |stat|
            data = {
              :tags      => { name => label.downcase, "queue_name" => queue_name },
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
