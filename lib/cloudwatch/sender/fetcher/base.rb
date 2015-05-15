module Cloudwatch
  module Sender
    module Fetcher
      class Base
        attr_reader :components, :metric_prefix, :cloudwatch, :sender, :namespace

        def initialize(components, namespace)
          @components = components
          @metric_prefix = components["metric_prefix"]
          @namespace = namespace
          @sender = Cloudwatch::Sender::Base.new(components["influx_host"], components["influx_port"])
          @cloudwatch = Aws::CloudWatch::Client.new
        end

        def retrieve
          components["metric_types"].each do |component_meta|
            component_meta["metrics"].each do |metric|
              metric_type(component_meta, metric)
            end
          end
        end

        def metric_type(component_meta, metric)
          if namespace.start_with?("AWS/")
            id = "Cloudwatch::Sender::Fetcher::#{component_meta['namespace'].split('/').last}"
            build_message = Object.const_get(id).new(cloudwatch, sender, metric_prefix)
            build_message.metrics(component_meta, metric)
          else
            build_message = Cloudwatch::Sender::Fetcher::Custom.new(cloudwatch, sender, metric_prefix)
            build_message.metrics(component_meta, metric)
          end
        end
      end
    end
  end
end
