var path = require('path');
var xtend = require('xtend');
var isArray = require('is-array');
var isString = require('is-string');
var isObject = require('is-object');

module.exports = function run(opts, done) {
  // these modules are expected to be installed by the gem consumer (eg. the app)
  var WebpackDevServer = require('webpack-dev-server');
  var webpack = require('webpack');

  // TODO: extract to rails config
  opts = opts || {};
  opts.protocol = opts.protocol || 'http';
  opts.host = opts.host || 'localhost';
  opts.port = opts.port || 9876;
  opts.public_url = opts.public_url || opts.protocol + '://' + opts.host + ':' + opts.port;
  opts.webpack_config = opts.webpack_config || path.resolve('./config/webpack.config.js');

  var config = require(opts.webpack_config);
  // extend webpack config
  var devServerConfig = xtend(config, {
    output: xtend(config.output || {}, {
      publicPath: opts.public_url + '/',
    }),
    plugins: (config.plugins || []).concat(
     // https://webpack.github.io/docs/webpack-dev-server.html#hot-module-replacement
      new webpack.HotModuleReplacementPlugin()
    ),
    // TODO: extract to user webpack config
    devtool: (
      process.env.FAST_SOURCEMAPS ?
      'cheap-eval-source-map' :
      'inline-source-map'
    ),
  });

  // inject webpack-dev-server & hot module reload clients into each bundle
  var devServerClientScripts = [
    require.resolve('webpack-dev-server/client/') + '?' + opts.public_url,
    'webpack/hot/dev-server'
  ];

  if (isArray(devServerConfig.entry) || isString(devServerConfig.entry)) {
    devServerConfig.entry = devServerClientScripts.concat(devServerConfig.entry);
  } else if (isObject(devServerConfig.entry)) {
    devServerConfig.entry = {};
    Object.keys(config.entry).forEach(function(key) {
      devServerConfig.entry[key] = devServerClientScripts.concat(config.entry[key]);
    });
  } else {
    done(new Error("couldn't add hot reload client to config.entry"));
  }

  // spawn server
  var compiler = webpack(devServerConfig);
  var server = new WebpackDevServer(compiler, {
    hot: true,
    headers: {
      'Access-Control-Allow-Origin': '*' // CORS
    },
    // TODO: extract to user webpack config
    noInfo: true,
    stats: {
      colors: true
    },
  });

  server.listen(opts.port, opts.host, function() {
    done(null, server);
  });

  return server;
}
