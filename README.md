# Fields::Serializer

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/fields/serializer`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fields-serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fields-serializer

## Usage

Use example in your controller:

```ruby
class OrdersController < ApplicationController
  def index
    orders = Order.all
    render_json_fields(orders, model_class: Order, fields: ["short_id", "customer.first_name", "customer.surname", "customer.address.postcode"], root: "orders")
  end
end

```

If `:model_class` and `:fields` options are included, it will optimize the query to the db using `.includes` based
on the model_class associations found in `:fields` value. Also, will render only the fields in `:fields` option.

If no :model_class and `:fields` options are provided, it will render the whole objects using the appropriate model
serializer.

You can also provide any other options accepted by common `render` method.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ltello/fields-serializer.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
