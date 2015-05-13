loop do
  `cloudwatch-sender send_metrics "#{ENV['CONFIG']}" "#{ENV['AWS_ACCESS_KEY_ID']}" "#{ENV['AWS_SECRET_ACCESS_KEY']}" "#{ENV['AWS_REGION']}"`
  sleep ENV['TIME'].to_i
end
