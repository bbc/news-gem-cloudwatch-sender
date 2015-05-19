module Cloudwatch
  module Sender
    class MetricDefinition
      def self.metric_type(components)
        components["metric_types"].each do |component_meta|
          namespace = component_meta["namespace"]
          Cloudwatch::Sender::Fetcher::Base.new(components, namespace).retrieve component_meta
        end
      end
    end
  end
end
