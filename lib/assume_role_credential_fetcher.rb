require 'fog/aws'
require 'inifile'

class AssumeRoleCredentialFetcher
  DEFAULT_ROLE_SESSION_NAME = 'default_session'
  PROFILE_FILE = "#{Dir.home}/.aws/config"

  attr_reader :profile_name

  def initialize(profile_name)
    @profile_name = profile_name
  end

  def fetch_credentials
    sts = Fog::AWS::STS.new(use_iam_profile: true)
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
