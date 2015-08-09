module Cloudwatch
  module Sender
    module Fetcher
      class Custom
        attr_reader :cloudwatch, :sender, :database

        def initialize(cloudwatch, sender)
          @cloudwatch = cloudwatch
          @sender = sender
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
            data = {
              :tags      => {
                name.tr("^A-Za-z0-9", "") => label.downcase
              },
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
