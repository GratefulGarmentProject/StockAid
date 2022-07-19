process.env.NODE_ENV = process.env.NODE_ENV || 'review'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
