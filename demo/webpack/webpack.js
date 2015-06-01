var webpack = require('webpack');
var fs = require('fs');

var webpackConfig = require('./webpack.config');

var compiler = webpack(webpackConfig);

module.exports = function(opts, done) {
  compiler.run(function(err, stats) {
    if (err) return done(err);
    fs.writeFileSync('stats.json', JSON.stringify(Object.keys(stats), null, 2));
    done(null, {stats: Object.keys(stats)});
  });
}
