var path = require('path');
var querystring = require('querystring')
var xtend = require('xtend');
var isArray = require('is-array');
var isString = require('is-string');
var isObject = require('is-object');
var express = require('express');
var cors = require('cors');

// these modules are expected to be installed by the gem consumer (eg. the app)
var webpackDevMiddleware = require('webpack-dev-middleware');
var webpackHotMiddleware = require('webpack-hot-middleware');
var webpack = require('webpack');

var log = require('./log');
var ErrorMessagePlugin = require('./ErrorMessagePlugin');

process.on('exit', function(code) {
  log(process.pid+' About to exit with code:', code);
});

var server = null;
module.exports = function waitForServer(opts, done) {
  if (server) {
    log('webpack already running');
    return done(null, {started: false});
  }

  log('starting webpack');
  runWebpackDevServer(opts, function(err, createdServer) {
    if (err) {
      log.error(err);
      done(err);
    }

    server = createdServer;
    log('server started succesfully');
    done(null, {started: true});
  });
};

function runWebpackDevServer(opts, done) {
  opts = opts || {};
  opts.protocol = opts.protocol || 'http';
  opts.host = opts.host || 'localhost';
  opts.port = opts.port || 9876;
  opts.webpack_config_file = opts.webpack_config_file || path.resolve('./config/webpack.config.js');
  opts.dev_server_reload = opts.dev_server_reload === false ? false : true

  var devServerConfig;
  try {
    devServerConfig = makeDevServerConfig(opts);
  } catch (err) {
    done(err);
  }

  // create webpack compiler instance
  var compiler = webpack(devServerConfig);

  // create express app
  var app = express();
  app.use(cors({credentials: true, origin: true}));

  app.use(webpackDevMiddleware(compiler, {
    publicPath: devServerConfig.output.publicPath,
  }));

  app.use(webpackHotMiddleware(compiler));

  // spawn server
  var server = app.listen(opts.port, opts.host, function() {
    log('pid '+process.pid+' listening on '+opts.host+':'+opts.port);
    done(null, server);
  });

  return server;
}

function makeDevServerConfig(opts) {
  var config = require(opts.webpack_config_file);
  var publicUrl = opts.protocol+'://'+opts.host+':'+opts.port;

  // extend webpack config
  var devServerConfig = xtend(config, {
    output: xtend(config.output || {}, {
      publicPath: publicUrl+'/',
      path: path.resolve(config.output.path),
    }),
    plugins: (config.plugins || []).concat([
      new webpack.optimize.OccurenceOrderPlugin(),
       // https://webpack.github.io/docs/webpack-dev-server.html#hot-module-replacement
      new webpack.HotModuleReplacementPlugin(),
      new webpack.NoErrorsPlugin(),
      new ErrorMessagePlugin(),
    ]),
  });

  // inject webpack-dev-server & hot module reload clients into each bundle
  var devServerClientScripts = [
    require.resolve('webpack-hot-middleware/client')+'?'+querystring.stringify({
      path: publicUrl+'/__webpack_hmr',
      reload: opts.dev_server_reload,
    }),
  ];

  if (isArray(devServerConfig.entry) || isString(devServerConfig.entry)) {
    devServerConfig.entry = devServerClientScripts.concat(devServerConfig.entry);
  } else if (isObject(devServerConfig.entry)) {
    devServerConfig.entry = {};
    Object.keys(config.entry).forEach(function(key) {
      devServerConfig.entry[key] = devServerClientScripts.concat(config.entry[key]);
    });
  } else {
    throw new Error("couldn't add hot reload client to config.entry");
  }

  return devServerConfig;
}
