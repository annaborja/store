# Old Relic Social Club

An e-commerce web app. Back end built on [Ruby on Rails](http://rubyonrails.org/) and [SQLite](https://www.sqlite.org/).
Front end built with [Bootstrap 3](https://getbootstrap.com/docs/3.3/), [jQuery](https://jquery.com/), and [HTML5 Boilerplate](https://html5boilerplate.com/).

## Getting Started

Create a sandbox directory.

```bash
mkdir ~/my_sandbox && cd ~/my_sandbox
```

Clone the repo.

```bash
git clone git@github.com:annaborja/store.git && cd store
```

Run Bundler to install necessary gems.

```bash
bundle
```

Set up your local database.
```bash
# Create your development db and run all migrations.
rake db:create
rake db:migrate

# Seed your dev db with dummy data.
rake db:seed
```

Run the app (you will need our Stripe API test keys in order to make transactions through Stripe).

```bash
PUBLISHABLE_KEY=<stripe_publishable_key> SECRET_KEY=<stripe_secret_key> rails s
```

Navigate to http://localhost:3000/ in your web browser.

**PROFIT.**

## Development

We use [Rubocop](https://github.com/bbatsov/rubocop) for Ruby linting.
Make sure to run the linter before committing your code.

```bash
# Run Rubocop on the codebase.
rubocop

# Run Rubocop and let it autocorrect as many errors as it can.
rubocop -a
```

## Testing

We use [RSpec](http://rspec.info/) for unit and integration tests and
[factory_bot](https://github.com/thoughtbot/factory_bot) for test fixtures.
All PRs containing new code should also include specs for that code.

```bash
# Run the entire test suite.
bundle exec rspec

# Run only the tests in a particular directory or file.
bundle exec rspec <path_to_directory_or_file>
```
