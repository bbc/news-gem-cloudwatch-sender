loop do
  `cloudwatch-sender send_metrics metrics.yaml AWS_ACCESS_KEY_ID AWS_SECRET_KEY_GOES_HERE AWS_REGION`
  sleep 30
end
