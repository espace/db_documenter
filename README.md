# DatabaseDocumenter

Welcome to Database Documenter gem! We created this gem to generate database documentation for rails applications.

## Features

1. Generate database documentation as a `Word document` or `Markdown file`.
2. Generate Description for columns based on it is type and name, Also handle Enums and STI and AASM.
3. Easy to change the generated description by adding a comment on your database.
4. Hide sample values of desired columns using configuration.
5. You can Ignore models inside certain namespaces.
6. Works on MySQL and PostgreSQL database.

## Installation

```ruby
gem 'database_documenter'
```

And then execute:

    $ bundle install

## Configuration

To generate the gem configuration file run this rake task in the application directory

    $ bundle exec rake generate_dd_initializer

or create the configuration file manually in this path `config/initializers/database_documenter.rb` :

```ruby
DatabaseDocumenter.configure do |config|
  config.skipped_modules = %w(NAMESPACE)
  config.hidden_values_columns = %w(col1 col2)
  config.footer = "Generated by Company" # Footer beside the pagination
end
```

## Usage

### To Generate the Word document

In the application directory run this rake task and then you will find a word document named `database.docx` in your application directory:

    $ bundle exec rake generate_db_document

### To Generate the Markdown file

Run the following rake task and then you will find a markdown file named `database.md` in your application directory:

    $ bundle exec rake generate_db_md_document

## Override generated description
You can override it by adding comment to your schema using one of the following options:

### Rails 4
use [migration comments](https://github.com/pinnymz/migration_comments) gem or [pg_comment](https://github.com/albertosaurus/pg_comment)

### Rails 5.2
use `change_column_comment` and `change_table_comment` methods in rails 5

## Contribution

- Fork & create a branch
- bundle install
- Make sure to run `overcommit --install` before working to run RuboCop before push.
- Create Pull Request.

## TODO

- Generate the ERD with the file.
- Add test cases.
- Update `DatabaseDocumenter::TableDat`a to return the `sql_code` as a `String`.
