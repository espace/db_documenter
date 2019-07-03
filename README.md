# DatabaseDocumenter

Welcome to Database Documenter gem! We created this gem to generate database documentation for rails applications.
## Installation

```ruby
gem 'database_documenter', git: 'https://github.com/espace/db_documenter.git'
```

And then execute:

    $ bundle install

## Override generated description
You can override it by adding comment to your schema using one of the following options:

### Rails 4
use [migration comments](https://github.com/pinnymz/migration_comments) gem or [pg_comment](https://github.com/albertosaurus/pg_comment)

### Rails 5
use `change_column_comment` and `change_table_comment` methods in rails 5

## Usage

in the application folder run this rake task and then you will found word document named `database.docx` in your application folder:

    $ bundle exec rake generate_db_document

## TODO

- Make It configurable, Configurations like (page footer, dont_display_columns list).
- Test it in PostgreSQL database, currently working on MySQL database.
