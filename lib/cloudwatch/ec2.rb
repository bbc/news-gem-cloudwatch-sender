require "aws-sdk"

class EC2
  attr_reader :ec2

  def initialize(key_id, access_key, region)
    @ec2 = Aws::EC2::Client.new(
      :region            => region,
      :access_key_id     => key_id,
      :secret_access_key => access_key
    )
  end

  def list_instances(key, value)
    resp = ec2.describe_instances(
      filters: [
        {
          name: "tag-key",
          values: [key]
        },
        {
          name: "tag-value",
          values: [value]
        }
      ]
    )

    list_instance_ids(resp)
  end

  private

  def list_instance_ids(instances)
    instances.reservations.map do |reservations|
      reservations.instances.map(&:instance_id)
    end
  end
end
