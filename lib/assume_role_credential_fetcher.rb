require 'fog/aws'
require 'inifile'

class AssumeRoleCredentialFetcher
  DEFAULT_AWS_REGION='us-east-1'
  DEFAULT_ROLE_SESSION_NAME = 'default_session'

  PROFILE_FILE = "#{Dir.home}/.aws/config"

  attr_reader :profile_name, :region

  def initialize(profile_name, region=DEFAULT_AWS_REGION)
    @profile_name = profile_name
    @region = region
  end

  def fetch_credentials
    sts = Fog::AWS::STS.new(use_iam_profile: true, region: region)
    sts.assume_role(DEFAULT_ROLE_SESSION_NAME, role_arn)
  end

  def role_arn
    config_for_profile['role_arn']
  end

  def config_for_profile
    ini_file = IniFile.load(PROFILE_FILE)
    ini_file.to_h["profile #{profile_name}"]
  end

  def credentials
    response = fetch_credentials
    response.body
  end
end
