module Cloudwatch
  module Sender
    module Fetcher
      class Base
        def initialize(components, namespace)
          @components = components
          @namespace  = namespace
        end

        def retrieve(component_meta)
          component_meta["metrics"].each do |metric|
            metric_type(component_meta, metric)
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
          namespace.start_with?("AWS/EC2") || namespace.start_with?("AWS/SQS") ? Object.const_get(class_namespace component_meta) : Cloudwatch::Sender::Fetcher::Custom
        end

        def class_namespace(component_meta)
          "Cloudwatch::Sender::Fetcher::#{extract_class_name component_meta}"
        end

        def metric_prefix
          components["metric_prefix"]
        end

        def metric_type(component_meta, metric)
          fetcher(component_meta).new(
            cloudwatch, sender
          ).metrics(component_meta, metric)
        end

        def sender
          Cloudwatch::Sender::Base.new(
            components["influx_options"], metric_prefix
          )
        end
      end
    end
  end
end
