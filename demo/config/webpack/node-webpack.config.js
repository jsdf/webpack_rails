var webpack = require('webpack');
var path = require('path');
var fs = require('fs');
var _ = require('underscore');
 
var commonWebpackConfig = require('./common-webpack.config');
 
var nodeModules = {};
fs.readdirSync('node_modules')
  .filter(function(x) {
    return ['.bin'].indexOf(x) === -1;
  })
  .forEach(function(mod) {
    nodeModules[mod] = 'commonjs ' + mod;
  });
 
module.exports = _.extend({}, commonWebpackConfig, {
  entry: './lib/assets/modules/ca-react-node-render/index.js',
  target: 'node',
  output: {
    path: './tmp/webpack',
    filename: 'react-render.node.js'
  },
  externals: nodeModules,
  plugins: [
    new webpack.IgnorePlugin(/\.(css|less|scss|sass)$/),
    new webpack.BannerPlugin('require("source-map-support").install();', { raw: true, entryOnly: false })
  ],
  devtool: 'sourcemap'
});
