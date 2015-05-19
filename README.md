# Cloudwatch::Sender

Cloudwatch-sender retrieves metrics from Cloudwatch and sends them to InfluxDB/Graphite.  

Most of the tools similar to this don't take into consideration lots of deploys with new values.  Configs become quickly out of date with options such as instance ID's.  For that reason, cloudwatch-sender fetches metrics based on more broad criteria, such as tag keys and values.  This allows for deploys to occur and not require a config update.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "cloudwatch-sender"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudwatch-sender

## Usage

This Gem works different to most tools in that you provide a tag key for your EC2 instances.  This could be name for example, where the value is the name of your instance.  In our use case, we break down by component, so each of our instances are attached to a component namespace that we can reference later.  When we call that namespace, it returns all the instances attached to it, which would be 25-30 for normal production website.

```sh
cloudwatch-sender send_metrics configs/metrics.yaml $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_REGION
```

If you want to run a continuous stream of metrics, you can use the following command

```sh
cloudwatch-sender continous configs/metrics.yaml $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_REGION 60
```

By default the sleep time is 60, but you can override that as shown above.  

Metrics are collected for the previous 180 for EC2 and 12000 seconds for SQS, running once every 60 seconds for EC2 and every 5 minutes for SQS should provide graphs with sufficient data.  The reason for these timings is in the event you have network issues or issues with the database on the receiving end.  SQS also only updates every 5 minutes, so request the 2 previous metrics is prudent for consistent graphs.


## Configs

There is a defined structure for the yaml files to power cloudwatch-sender, these include extra options based on the metric that you may be using.  
Copy the metrics.yaml.example to get started.

## TODO

Add support for more metrics

## License

Standard MIT License, see included license file.

## Credits

 - [David Blooman](@dblooman)
 - [Charlie Revett](@charlierevett)

## Contributing

1. Fork it ( https://github.com/bbc-news/cloudwatch-sender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
