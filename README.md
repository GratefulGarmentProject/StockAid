[![Build Status](https://travis-ci.org/on-site/StockAid.svg?branch=master)](https://travis-ci.org/on-site/StockAid)

![StockAid Logo](StockAid.png)

## Development Environment

Run `rake setup` to prepare the necessary environment variables to begin
development. After that, you will need to run `rvm use .` to load the
environment variables generated in `.ruby-env`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/on-site/StockAid. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](CODE_OF_CONDUCT.md) code of conduct.

## License

This project is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

## Mac Setup

If you are on the Mac, follow these steps (with caution):

```
brew update
brew install postgresql
git clone https://github.com/on-site/StockAid.git
\curl -sSL https://get.rvm.io | bash -s stable
rvm install `cat .ruby-version`
cd .
gem install bundler
bundle
rake setup
rvm use .
spring stop
# now to start your postgres db
postgres -D /usr/local/var/postgres/
```
