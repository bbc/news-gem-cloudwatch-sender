<h1 align="center">cloudwatch-sender</h1>

<p align="center">
  Retrieves metrics from <b>Cloudwatch</b> and sends them to <b>InfluxDB</b>/<b>Graphite</b>.
</p>

## What is this?

Allows you to send **EC2**, **SQS** and **custom** metrics from Cloudwatch to InfluxDB or Graphite. EC2 metrics are gathered via EC2 tags, instead of EC2 Instance ID, making the tool far more dynamic.

## Installation

Add this line to your Gemfile:

```ruby
gem "cloudwatch-sender"
```

Then execute:

```
bundle
```

Or install it yourself:

```
gem install cloudwatch-sender
```

## Usage

### Command Line

```sh
cloudwatch-sender send_metrics /path/to/config.yaml $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_REGION
```

If you would like to stream metrics to your endpoint at a set interval, use `continuous`:

```sh
cloudwatch-sender continuous /path/to/config.yaml $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_REGION $SLEEP_INTERVAL
```

**Note** - the default `$SLEEP_INTERVAL` is 60 seconds.

### Programmatically

```ruby
require "cloudwatch/sender/cli"

loop do
  Cloudwatch::Sender::CLI.new.send_metrics(config_path, key_id, access_key, region)
  sleep 120
end
```

```ruby
require "cloudwatch/sender/cli"

Cloudwatch::Sender::CLI.new.continuous(config_path, key_id, access_key, region, sleep_time)
```

## Configs

The gem is powered via a YAML config file, see [metrics.yaml.example](https://github.com/BBC-News/cloudwatch-sender/blob/master/configs/metrics.yaml.example) for an example.

**Note**: take into account how often metrics update when using the tool:

- EC2 - every 60 seconds.
- SQS - every 5 minutes.

## How it works

The gem extracts metrics for a given set of EC2 instances based on a tag key/value. For example:

```yaml
ec2_tag_key:   ProjectName
ec2_tag_value: bbc_news
```

As seen in the example above a tag relates to a single project, so each of the instances for that project are attached to that key/value pair for easy reference. Thus that key/value is called, it returns all the instances attached to it - which is what the gem uses to gather metrics on each instance.

EC2 metrics are collected for the previous 3 minutes and SQS 20 minutes. Thus running the gem every 60 seconds for EC2 and every 5 minutes for SQS will provide sufficient data. This allows for the gem to remain unaffected by network/database issues.

## Why make this?

We found the existing tools heavily rely upon AWS variables which often become out-of-date, e.g. EC2 Instance ID. This becomes a problem when a component is being regularly re-built and deployed. Thus we made the decision to base cloudwatch-sender on a broder set of criteria, such as EC2 tags.

## TODO

See [open issues](https://github.com/BBC-News/cloudwatch-sender/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3Ato-do).

## License

Standard MIT License, see included [license file](https://github.com/BBC-News/cloudwatch-sender/blob/master/LICENSE.txt).

## Authors

- [David Blooman](http://twitter.com/dblooman)
- [Charlie Revett](http://twitter.com/charlierevett)

## Contributing

1. [Fork it!](https://github.com/bbc-news/cloudwatch-sender/fork)
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am "Add some feature"`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new [Pull Request](https://github.com/BBC-News/cloudwatch-sender/compare).

Please feel free to raise an [issue](https://github.com/BBC-News/cloudwatch-sender/issues/new) if you find a bug or have a feature request.
