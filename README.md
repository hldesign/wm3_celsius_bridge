# WM3 Celsius Bridge

This is the repo for the WM3 Celsius Bridge gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wm3_celsius_bridge'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wm3_celsius_bridge

## Configuration

The bridge is configured by environment variables.

```bash
# Set the user name for logging in to NAV
export NAV_USER_NAME="nav_user"
# Set the NTLM aurhentication domain for logging in to NAV
export NAV_USER_DOMAIN="nav_domain"
# Set the password for logging in to NAV
export NAV_PASSWORD="nav_password"
# Set the NAV SOAP endpoint
export NAV_ENDPOINT="http://example.com/soap/endpoint"
```
```ruby
# You can then configure the bridge in the code
CelsiusBridge.configure do |config|
  config.user_name = ENV['NAV_USER_NAME']
  config.user_domain = ENV['NAV_USER_DOMAIN']
  config.password = ENV['NAV_PASSWORD']
  config.endpoint = ENV['NAV_ENDPOINT']
end
```

## Usage

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hldesign/wm3_celsius_bridge.
