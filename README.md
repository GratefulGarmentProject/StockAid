[![Build Status](https://travis-ci.org/on-site/StockAid.svg?branch=master)](https://travis-ci.org/on-site/StockAid)

![StockAid Logo](StockAidSlim.png)

## What is StockAid?

StockAid is an inventory management system for [The Grateful Garment Project](https://gratefulgarment.org)
which provides clothing for victims of sexual assault.

## Development Environment


Run `rake setup` to prepare the necessary environment variables to begin
development. After that, you will need to run `rvm use .` to load the
environment variables generated in `.ruby-env`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/GratefulGarmentProject/StockAid. This project is intended to be a safe,
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
cd .
${rvm_recommended_ruby}
gem install bundler
bundle
rake setup
rvm use .
spring stop
# now to start your postgres db
postgres -D /usr/local/var/postgres/
```

Note: the line `${rvm_recommended_ruby}` should install the version of Ruby
defined in `./Gemfile`. If this fails, please look at the Ruby version defined
on the top line, and run `rvm install ruby-x.x.x` (replacing `x.x.x` with the
version you see in the `Gemfile`).
