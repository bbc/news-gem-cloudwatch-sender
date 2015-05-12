# Cloudwatch::Sender

Get metrics from Cloudwatch and send to InfluxDB/Graphite.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloudwatch-sender'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudwatch-sender

## Usage

```
cloudwatch-sender send_metrics metrics.yaml AWSACCESSKEYID AWSSECRETKEYGOESHERE eu-west-1
```

Metrics are collected for the previous 60 seconds, running once every 30 seconds should provide graphs with sufficient data.

## Contributing

1. Fork it ( https://github.com/bbc-news/cloudwatch-sender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
