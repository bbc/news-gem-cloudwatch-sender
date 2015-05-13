class MetricDefinition
  def self.metric_type(components, key_id, access_key, region)
    components['metric_types'].each do |component_meta|
      case component_meta['namespace']
      when "AWS/EC2"
        EC2Fetcher.new(components, key_id, access_key, region).retrieve
      when "AWS/S3"
        S3Fetcher.new(components, key_id, access_key, region).retrieve
      else
        CustomFetcher.new(components, key_id, access_key, region).retrieve
      end
    end
  end
end
