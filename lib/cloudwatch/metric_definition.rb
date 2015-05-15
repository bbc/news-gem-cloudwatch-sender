class MetricDefinition
  def self.metric_type(components, key_id, access_key, region)
    components['metric_types'].each do |component_meta|
      namespace = component_meta['namespace']
      Cloudwatch::Sender::Fetcher::Base.new(components, key_id, access_key, region, namespace).retrieve
    end
  end
end
