var path = require('path');
var glob = require('glob');
var webpack = require('webpack');

var components = glob.sync('app/assets/components/*/').reduce(function(memo, p) {
  memo[path.basename(p)] = path.resolve(p);
  return memo;
}, {});

module.exports = {
  entry: components,
  output: {
    filename: '[name].bundle.js', // Template based on keys in entry above
    path: './tmp/webpack', // This is where images AND js will go
    publicPath: '/$asset_root/', // This is used to generate URLs to e.g. images
  },
  resolve: {
    root: path.resolve('./app/assets/components'),
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin('common.bundle.js'),
  ],
  module: {
    loaders: [
      {test: /\.s(c|a)ss$/, loader: 'style!css!sass'}, // use ! to chain loaders
      {test: /\.less$/, loader: 'style!css!less'},
      {test: /\.css$/, loader: 'style!css'},
      {test: /\.(png|jpg)$/, loader: 'url?limit=8192'}, // inline base64 URLs for <=8k images, direct URLs for the rest
      {test: /\.coffee$/, loader: 'coffee'},
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel',
        // loader opts
        query: {
          optional: ['runtime', 'spec.protoToAssign'],
          loose: ['es6.classes', 'es6.properties.computed', 'es6.modules'],
        },
      },
    ]
  }
};
