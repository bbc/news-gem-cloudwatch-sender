require "cloudwatch/sender/base"

module Cloudwatch
  module Sender
    module Fetcher
      class Base
        def initialize(components, namespace)
          @components = components
          @namespace  = namespace
        end

        def retrieve
          components["metric_types"].each do |component_meta|
            component_meta["metrics"].each do |metric|
              metric_type(component_meta, metric)
            end
          end
        end

        private

        attr_reader :components, :namespace

        def cloudwatch
          Aws::CloudWatch::Client.new
        end

        def extract_class_name(component_meta)
          component_meta["namespace"].split("/").last
        end

        def fetcher(component_meta)
          namespace.start_with?("AWS/") ? Object.const_get(id component_meta)
                                        : Cloudwatch::Sender::Fetcher::Custom
        end

        def id(component_meta)
          "Cloudwatch::Sender::Fetcher::#{extract_class_name component_meta}"
        end

        def metric_prefix
          components["metric_prefix"]
        end

        def metric_type(component_meta, metric)
          fetcher(component_meta).new(
            cloudwatch, sender, metric_prefix
          ).metrics(component_meta, metric)
        end

        def sender
          Cloudwatch::Sender::Base.new(
            components["influx_host"], components["influx_port"]
          )
        end
      end
    end
  end
end
