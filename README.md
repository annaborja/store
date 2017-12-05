# Old Relic Social Club

A Rails e-commerce web app.

## Getting Started

Create a sandbox directory.

```bash
mkdir ~/my_sandbox && cd ~/my_sandbox
```

Clone the repo.

```bash
git clone git@github.com:annaborja/store.git && cd store
```

Run the app (you will need our Stripe API test keys in order to make transactions through Stripe).

```bash
PUBLISHABLE_KEY=<stripe_publishable_key> SECRET_KEY=<stripe_secret_key> rails s
```

Navigate to http://localhost:3000/ in your web browser.

**PROFIT.**

## Testing

We use [RSpec](http://rspec.info/) for unit and integration tests and
[factory_bot](https://github.com/thoughtbot/factory_bot) for test fixtures.
All PRs containing new code should also include specs for that code.

### How to run tests

```bash
# Run the entire test suite.
bundle exec rspec

# Run only the tests in a particular directory or file.
bundle exec rspec <path_to_directory_or_file>
```
