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


```sh
cloudwatch-sender send_metrics metrics.yaml $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_REGION
```

If you want to run a continuous stream of metrics, you can use the following command

```sh
cloudwatch-sender continous metrics.yaml $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_REGION 60
```

By default the sleep time is 60, but you can override that as shown above.  

Metrics are collected for the previous 180 seconds, running once every 60 seconds should provide graphs with sufficient data.  The reason for 180 seconds is in the event you have network issues or issues with the database on the receiving end.


## Configs

There is a defined structure for the yaml files to power cloudwatch-sender, these include extra options based on the metric that you may be using.  
Copy the metrics.yaml.example to get started.


## Contributing

1. Fork it ( https://github.com/bbc-news/cloudwatch-sender/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
