path = require 'path'
americano = require 'americano'
bodyParser = require 'body-parser'

staticMiddleware = americano.static path.resolve(__dirname, '../client/public'),
            maxAge: 86400000

publicStatic = (req, res, next) ->
    url = req.url
    req.url = req.url.replace '/public/assets', ''
    staticMiddleware req, res, (err) ->
        req.url = url
        next err

GB = 1024 * 1024 * 1024
config =
    maxFileSize: 2 * GB
    common:
        set:
            'view engine': 'jade'
            'views': path.resolve __dirname, 'views'
        use: [
            bodyParser()
            require('cozy-i18n-helper').middleware
            americano.errorHandler
                dumpExceptions: true
                showStack: true

            staticMiddleware
            publicStatic

        ]
    development: [
        americano.logger 'dev'
    ]
    production: [
        americano.logger 'short'
    ]
    plugins: [
        'americano-cozy'
    ]

module.exports = config
