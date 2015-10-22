var fs = require('fs');
var path = require('path');
var xtend = require('xtend');
var isArray = require('is-array');
var isString = require('is-string');
var isObject = require('is-object');

var loggingToFile = Boolean(process.env.WEBPACK_TASK_LOGGING);

process.on('exit', function(code) {
  log(process.pid+' About to exit with code:', code);
});

var server = null;
module.exports = function waitForServer(opts, done) {
  if (server) {
    log('webpack already running');
    return done();
  }

  log('starting webpack');
  runWebpackDevServer(opts, function(err, createdServer) {
    if (err) {
      logErr(err);
      done(err);
    }

    server = createdServer;
    log('server started succesfully');
    done();
  })
};

function runWebpackDevServer(opts, done) {
  // these modules are expected to be installed by the gem consumer (eg. the app)
  var WebpackDevServer = require('webpack-dev-server');
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
    require.resolve('webpack-dev-server/client/') + '?' + publicUrl,
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
