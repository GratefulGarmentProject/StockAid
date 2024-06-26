const { webpackConfig, merge } = require('shakapacker')
const coffee = require('./loaders/coffee')
const webpack = require('webpack')

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const customConfig = {
  plugins: [
    new webpack.ProvidePlugin({
      tmpl: 'blueimp-tmpl/js/tmpl'
    })
  ]
};

module.exports = merge(webpackConfig, customConfig)
