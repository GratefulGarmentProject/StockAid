[![Build Status](https://travis-ci.org/on-site/StockAid.svg?branch=master)](https://travis-ci.org/on-site/StockAid)

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

## OSX Setup

1. Install Postgres at postgresapp.com

2. Install dependencies

    ```
    sudo brew update
    sudo brew install imagemagick
    git clone https://github.com/on-site/grantzilla.git
    ```

3. Install RVM, if you don't have it already

    ```
    \curl -sSL https://get.rvm.io | bash -s stable
    rvm install `cat .ruby-version`
    cd .
    ```

4. Install gems

    ```
    gem install bundler
    bundle
    ```

5. Run app setup

    ```
    rake setup
    rvm use .
    spring stop
    ```
