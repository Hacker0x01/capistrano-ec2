# Capistrano::Ec2

Useful for dynamically building a list of Amazon EC2 instances to deploy to.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-ec2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-ec2


## Configuration

Set the AWS region in which your instances live in the Capistrano deploy configuration:

**config/deploy.rb**
```ruby
set :region, 'us-west-2'
```

### Using a credentials file

Since it's a bad practice to have your credentials in source code, you should load them from default fog configuration file: `~/.fog`. This file could look like this:

```
default:
  aws_access_key_id:     <YOUR_ACCESS_KEY_ID>
  aws_secret_access_key: <YOUR_SECRET_ACCESS_KEY>
```

### Using IAM instance profiles

As an alternative to directly using credentials, you can also use IAM instance profiles by setting `:use_iam_profile` to `true` in the deploy configuration.

**config/deploy.rb**
```ruby
set :use_iam_profile, true
```

### Using assume role configured in AWS configuration profile

As an alternative to directly using credentials, you can configure capistrano-ec2 to assume a role by setting `:assume_role_using_profile` to the desired AWS profile in yuou configuration file that contains the role in its `role_arn` directive. This will use the instance its IAM Profile.

**config/deploy.rb**
```ruby
set :assume_role_using_profile, '<profile_name>'
```

This will read the AWS profile configuration from `~/.aws/config` and is expecting the following profile defined:

**~/.aws/config**
```
[profile <profile_name>]
role_arn = arn:aws:iam::AWS_ACCOUNT:role/<some_role_name>
credential_source = Ec2InstanceMetadata
```

The `role_arn` configured here will be the assumed role.


## Usage

Tag your EC2 instances so you can target specific servers in your Capistrano configuration.

Here is how to target all `production` `application-servers`:

```ruby
for_each_ec2_server(ec2_env: "production", ec2_role: "application-server") do |ec2_server|
  server ec2_server.private_ip_address, user: 'deploy', roles: roles
end
```

### Tagging single server with additional role

You'd probably want to have a single instance that is tagged with the "db" role. The seconds argument in the `do` block of `for_each_ec2_server` is the index of the current loop, you can use this as follows:

```ruby
for_each_ec2_server(ec2_env: "production", ec2_role: "application-server") do |ec2_server, index|
  # Only add "db" role to the first server
  roles = index.zero? ? %w(db app) : %w(app)

  server ec2_server.private_ip_address, user: 'deploy', roles: roles
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomdev/capistrano-ec2.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
