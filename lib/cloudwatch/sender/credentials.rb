module Cloudwatch
  module Sender
    class SetupAwsCredentials
      def self.iam(options)
        provider(options)
      end

      def self.instance_profile(options)
        provider(options)
      end

      def self.access_key_id(options)
        credentials = Aws::Credentials.new(options["access_key_id"], options["secret_access_key"])
        Aws.config.update(:region => (options["region"] || ENV["AWS_REGION"]), :credentials => credentials)
      rescue
        RequiredArgumentMissingError.new("'--access_key_id' and '--secret_access_key' required")
      end

      private

      def self.credentials
        Aws::InstanceProfileCredentials.new
      end

      def self.provider(options)
        Aws.config.update(:region => (options["region"] || ENV["AWS_REGION"]), :credentials => credentials)
      end
    end
  end
end
