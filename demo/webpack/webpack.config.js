var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: {
    a: 'a',
    b: 'b',
  },
  output: {
    filename: '[name].js', // Template based on keys in entry above
    path: './build', // This is where images AND js will go
    publicPath: '/$asset_root/', // This is used to generate URLs to e.g. images
  },
  resolve: {
    root: path.resolve('./app/assets/modules'),
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin('common.js'),
  ],
  module: {
    loaders: [
      {test: /\.sass$/, loader: 'style-loader!css-loader!sass-loader'}, // use ! to chain loaders
      {test: /\.css$/, loader: 'style-loader!css-loader'},
      {test: /\.(png|jpg)$/, loader: 'url-loader?limit=8192'}, // inline base64 URLs for <=8k images, direct URLs for the rest
    ]
  }
};
