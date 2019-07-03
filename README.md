# DatabaseDocumenter

Welcome to Database Documenter gem! We created this gem to generate database documentation for rails applications.
## Installation

```ruby
gem 'database_documenter', git: 'https://github.com/espace/db_documenter.git'
```

And then execute:

    $ bundle install

## Usage

in the application folder run this rake task and then you will found word document named `database.docx` in your application folder:

    $ bundle exec rake generate_db_document

## TODO

- Make It configurable, Configurations like (page footer, dont_display_columns list).
- Test it in PostgreSQL database, currently working on MySQL database.
