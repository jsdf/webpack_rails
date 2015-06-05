var webpack = require('webpack');
var fs = require('fs');

var webpackConfig = require('./webpack.config');

// run webpack watch via API
webpack(webpackConfig).watch({
  aggregateTimeout: 300, // wait so long for more changes
}, function(err, stats) {
  if (err) return console.error(err);
  if (stats.hasErrors()) {
    stats.toJson({errorDetails: true}).errors.forEach(function (errorMsg) {
      console.error(errorMsg);
    }) 
    return;
  }

  console.log('successfully built bundles');

  var buildResult = stats.toJson({
    hash: true,
    assets: true,
    modules: true,
    cached: true,
  });

  fs.writeFile('webpack-build-result.json', JSON.stringify(buildResult, null, 2));
});
