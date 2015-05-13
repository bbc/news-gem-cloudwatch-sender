loop do
  `cloudwatch-sender send_metrics metrics.yaml AWSACCESSKEYID AWSSECRETKEYGOESHERE eu-west-1`
  sleep 30
end
