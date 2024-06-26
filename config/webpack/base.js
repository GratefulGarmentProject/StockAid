const { webpackConfig, merge } = require('@rails/webpacker')
const coffee = require('./loaders/coffee')
const webpack = require('webpack')

const customConfig = {
  plugins: [
    new webpack.ProvidePlugin({
      tmpl: 'blueimp-tmpl/js/tmpl'
    })
  ]
};

module.exports = merge(webpackConfig, customConfig)
