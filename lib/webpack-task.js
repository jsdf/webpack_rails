var webpack = require('webpack');
var fs = require('fs');
var path = require('path');

var logging = true;
function log(message) {
  if (logging) fs.appendFile('log/webpack-task.log', message+'\n');
}

// TODO: add support for multiple builds using multiple webpack configs which 
// can each be waited upon independently
var webpackConfig = require(path.resolve('config/webpack.config.js'));

// webpack Compiler.Watching instance
var watcher = makeWatcher();
// callbacks which will be called when next build completes
var currentBuildCallbacks = [];
// object with property 'stats' for success or 'error' for failure
var lastBuildResult = null;

function buildComplete(buildResult) {
  lastBuildResult = buildResult;

  currentBuildCallbacks.forEach(function(callback) {
    log('async completion callback');
    callback(buildResult);
  });
  currentBuildCallbacks = [];

  fs.writeFile('tmp/webpack/webpack-build-result.json', JSON.stringify(buildResult, null, 2));
}

function makeWatcher() {
  return webpack(webpackConfig).watch({
    aggregateTimeout: 300, // wait so long for more changes
  }, function(err, stats) {
    if (err) {
      buildComplete({
        error: err,
      });
    } else if (stats.hasErrors()) {
      var errWithDetails = new Error('Webpack build error');
      errWithDetails.stack = (
        'Webpack build error:\n' +
        stats.toJson({errorDetails: true}).errors.join("\n") + ''
        // err ? '\nOriginal stacktrace:\n' + (err.stack || err) : ''
      );

      buildComplete({
        error: errWithDetails,
      });
    } else {
      var statsData = stats.toJson({
        hash: true,
        assets: true,
        modules: true,
        chunkOrigins: true,
        cached: true,
      });

      var modules = statsData.modules.map(function(moduleStats) {
        var loadersEnd = moduleStats.identifier.lastIndexOf('!')
        return moduleStats.identifier.slice(loadersEnd == -1 ? 0 : loadersEnd+1)
      })

      buildComplete({
        // stats: statsData,
        modules: modules,
      });
    }
  });
}

module.exports = function waitForBuild(opts, done) {
  function sendResults(buildResult) {
    if (buildResult.error) done(buildResult.error);
    else done(null, buildResult);
  }

  log('watcher.running: '+JSON.stringify(watcher.running));

  if (!watcher.running) {
    sendResults(lastBuildResult);
  } else {
    currentBuildCallbacks.push(sendResults);
  }
};
