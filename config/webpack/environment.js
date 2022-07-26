const { environment } = require('@rails/webpacker')
const coffee =  require('./loaders/coffee')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    tmpl: 'blueimp-tmpl/js/tmpl'
  })
)

environment.loaders.prepend('coffee', coffee)
module.exports = environment
