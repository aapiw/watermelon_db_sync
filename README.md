
# WatermelonDbSync

Make synchronize pull & push easier & faster.

This gem is built to handle synchronize between pull & push with [WatermelonDb](https://github.com/Nozbe/WatermelonDB) even you are use different library and keep the synchronization throguh API then you can use this gem, basically this gem follows this article to handle the sync [How to Build WatermelonDB Sync Backend in Elixir](https://fahri.id/posts/how-to-build-watermelondb-sync-backend-in-elixir) which is using Auto-incrementing Counter (Version) + Timestamp for Tracking Changes approach, but this is a Ruby version of it

## Features

- Seamless sync between WatermelonDB and Rails through API endpoint.
- Customizable sync strategies.
- Easy integration with existing Rails applications.
- Supported Postgresql


# WatermelonDB Sync

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'watermelon_db_sync'
```

You can find the gem on [RubyGems](https://rubygems.org/gems/watermelon_db_sync).

After updating the Gemfile, run:

```bash
$ bundle install
```

Or, install the gem manually using:

```bash
$ gem install watermelon_db_sync
```

## Getting Started

To set up the gem, you need to run the installation generator:

```bash
rails generate watermelon_db_sync:install
```

This will:
- Create an initializer at `config/initializers/watermelon_db_sync.rb` where all configuration options are described.
- Generate a migration to create a global sequence table: `db/migrate/[timestamp]_create_sequence.rb`.

### Adding Sync Fields to a Model

Once you have the basic setup, you can add sync fields to an existing model. This assumes that the table (e.g., `orders`) already exists in your database. To add sync fields, run:

```bash
rails generate watermelon_db_sync:add_sync_fields Order
```

This will generate a migration that adds the necessary sync fields to the `orders` table.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aapiw/watermelon_db_sync. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/aapiw/watermelon_db_sync/blob/master/CODE_OF_CONDUCT.md).