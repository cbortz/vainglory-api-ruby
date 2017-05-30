# vainglory-api
[![Gem Version](https://badge.fury.io/rb/vainglory-api.svg)](https://badge.fury.io/rb/vainglory-api)
[![Travis CI](https://travis-ci.org/cbortz/vainglory-api-ruby.svg?branch=master)](https://travis-ci.org/cbortz/vainglory-api-ruby)
[![Code Climate](https://codeclimate.com/github/cbortz/vainglory-api-ruby/badges/gpa.svg)](https://codeclimate.com/github/cbortz/vainglory-api-ruby)
[![Test Coverage](https://codeclimate.com/github/cbortz/vainglory-api-ruby/badges/coverage.svg)](https://codeclimate.com/github/cbortz/vainglory-api-ruby/coverage)
[![Inline docs](http://inch-ci.org/github/cbortz/vainglory-api-ruby.svg?branch=master)](http://inch-ci.org/github/cbortz/vainglory-api-ruby)

## Getting Started

VaingloryAPI works with Ruby 2.0 onwards. You can add it to your Gemfile with:

```ruby
gem 'vainglory-api'
```

Then run `bundle install`

You can also install it manually with:

```bash
gem install vainglory-api
```

### Usage

You can create an instance of the API client by initializing with your API key and [specified region](https://developer.vainglorygame.com/docs#regions) (`na` is the default):

```ruby
client = VaingloryAPI.new('YOUR_API_KEY', 'na')
```

#### Helper Attributes

All client methods return an `OpenStruct` object containing the response attributes with some additional helper attributes.

```ruby
response = client.samples

response.code     # The HTTP response code
response.success? # Returns true if the response code is less than 300
response.raw      # The complete HTTP response
```

#### Rate Limits

Each request will return data about your rate limits.

```ruby
response.rate_limit     # Request limit per day / per minute
response.rate_remaining # The number of requests left for the time window
response.rate_reset     # The remaining window before the rate limit is refilled in UTC epoch nanoseconds.
```

More information: https://developer.vainglorygame.com/docs#rate-limits

#### Filtering

Currently, filters are supported by these client methods:

- `VaingloryAPI#matches`
- `VaingloryAPI#samples`

You can pass filters in as a hash using the exact Query Parameter key names outlined in the [Vainglory API Documentation](https://developer.vainglorygame.com/docs).

```ruby
# Example matches request with filter
client.matches('filter[playerNames]' => 'boombastic04,IHaveNoIdea')
```

#### Methods

To get __multiple matches__:

```ruby
client.matches
```

To get __single match data__, you must provide the ID of a match:

```ruby
client.match('37f94e56-1360-11e7-a250-062445d3d668')
```

You can search for data of __one or more players__ by passing their in-game names (IGNs):

```ruby
client.players('boombastic04', 'IHaveNoIdea')
```

To get data about a __single player__, you must provide the ID of the player:

```ruby
client.player('6abb30de-7cb8-11e4-8bd3-06eb725f8a76')
```

To get __Telemetry__ data, you must provide the data URL:

```ruby
client.telemetry('https://gl-prod-us-east-1.s3.amazonaws.com/assets/semc-vainglory/na/2017/03/28/03/07/b0bb7faf-1363-11e7-b11e-0242ac110006-telemetry.json')
```

## License
[MIT License](LICENSE). Copyright 2017 Chet Bortz
