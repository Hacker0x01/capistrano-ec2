require 'fog/aws'

require_relative('../../assume_role_credential_fetcher')

module Capistrano
  class Configuration
    def ec2
      configuration = {
        provider: 'AWS',
        region: fetch(:region)
      }

      if assume_role_using_profile
        assumed_role_credentials = AssumeRoleCredentialFetcher.new(assume_role_using_profile).credentials

        configuration['aws_session_token'] = assumed_role_credentials['SessionToken']
        configuration['aws_access_key_id'] = assumed_role_credentials['AccessKeyId']
        configuration['aws_secret_access_key'] = assumed_role_credentials['SecretAccessKey']
      else
        configuration[:use_iam_profile] = fetch(:use_iam_profile, false)
      end

      Fog::Compute.new(configuration)
    end

    def for_each_ec2_server(ec2_env:, ec2_role:, &block)
      filters = {
        "tag:ec2_env" => ec2_env,
        "tag:role" => ec2_role,
        'instance-state-name': 'running'
      }

      ec2.servers.all(filters).map.with_index do |ec2_server, index|
        next unless ec2_server.ready?

        yield ec2_server, index
      end
    end

    private

    def assume_role_using_profile
      @assume_role_using_profile ||= fetch(:assume_role_using_profile, false)
    end
  end

  module DSL
    module Env
      def_delegators :env, :for_each_ec2_server
    end
  end
end
