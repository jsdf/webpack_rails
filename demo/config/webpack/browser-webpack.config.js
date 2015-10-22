var path = require('path');
var glob = require('glob');
var webpack = require('webpack');
var _ = require('underscore');
 
var commonWebpackConfig = require('./common-webpack.config');
 
module.exports = _.extend({}, commonWebpackConfig, {
  entry: entrypoints,
  output: {
    filename: '[name].bundle.js', // Template based on keys in entry above
    path: './tmp/webpack', // This is where images AND js will go
    publicPath: '/$asset_root/', // This is used to generate URLs to e.g. images
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin('common.bundle.js'),
  ],
});
