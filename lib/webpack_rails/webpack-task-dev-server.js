var fs = require('fs');
var path = require('path');
var xtend = require('xtend');
var isArray = require('is-array');
var isString = require('is-string');
var isObject = require('is-object');
var express = require('express');
var cors = require('cors');

var loggingToFile = Boolean(process.env.WEBPACK_TASK_LOGGING);

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
      logErr(err);
      done(err);
    }

    server = createdServer;
    log('server started succesfully');
    done(null, {started: true});
  });
};

function runWebpackDevServer(opts, done) {
  // these modules are expected to be installed by the gem consumer (eg. the app)
  var webpackDevMiddleware = require('webpack-dev-middleware');
  var webpackHotMiddleware = require('webpack-hot-middleware');
  var webpack = require('webpack');

  opts = opts || {};
  opts.protocol = opts.protocol || 'http';
  opts.host = opts.host || 'localhost';
  opts.port = opts.port || 9876;
  opts.webpack_config_file = opts.webpack_config_file || path.resolve('./config/webpack.config.js');
  var publicUrl = opts.protocol + '://' + opts.host + ':' + opts.port;

  var config = require(opts.webpack_config_file);

  // extend webpack config
  var devServerConfig = xtend(config, {
    output: xtend(config.output || {}, {
      publicPath: publicUrl + '/',
      path: path.resolve(config.output.path),
    }),
    plugins: (config.plugins || []).concat([
      new webpack.optimize.OccurenceOrderPlugin(),
       // https://webpack.github.io/docs/webpack-dev-server.html#hot-module-replacement
      new webpack.HotModuleReplacementPlugin(),
      new webpack.NoErrorsPlugin(),
    ]),
  });

  // inject webpack-dev-server & hot module reload clients into each bundle
  var devServerClientScripts = [
      require.resolve('webpack-hot-middleware/client') + '?path=' + publicUrl + '/__webpack_hmr',
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

  // create express app
  var app = express();
  app.use(cors({credentials: true, origin: true}));

  var compiler = webpack(devServerConfig);

  app.use(webpackDevMiddleware(compiler, {
    publicPath: devServerConfig.output.publicPath,
    headers: {
      'Access-Control-Allow-Origin': '*' // CORS
    },
  }));

  app.use(webpackHotMiddleware(compiler));

  // spawn server
  var server = app.listen(opts.port, opts.host, function() {
    log('listening on '+publicUrl)
    log('pid '+process.pid)
    done(null, server);
  });

  return server;
}

function log(message) {
  if (loggingToFile) fs.appendFileSync('log/webpack-task.log', new Date()+' -- '+message+'\n');
}

function logErr(err) {
  log(err.toString()+' -- '+JSON.stringify(err.stack));  
}
