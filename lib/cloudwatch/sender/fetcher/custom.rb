module Cloudwatch
  module Sender
    module Fetcher
      class Custom
        attr_reader :metric_prefix, :cloudwatch, :sender, :database

        def initialize(cloudwatch, sender, metric_prefix, database)
          @cloudwatch = cloudwatch
          @sender = sender
          @metric_prefix = metric_prefix
          @database = database
        end

        START_TIME = 18_000

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
            sender.send_tcp({ "database" => database, "points" => [{ "measurement" => metric_prefix, "tags" => { name.tr("^A-Za-z0-9", "") => label.downcase }, "time" => time, "fields" => { "value" => data[stat.downcase] } }] }.to_json)
          end
        end
      end
    end
  end
end
