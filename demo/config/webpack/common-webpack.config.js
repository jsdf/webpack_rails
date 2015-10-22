var path = require('path');
var glob = require('glob');

var APP_MODULES_DIR = path.resolve('app/assets/modules');
var LIB_MODULES_DIR = path.resolve('lib/assets/modules');

var entrypoints = glob.sync('app/assets/modules/*/').reduce(function(entrypoints, p) {
  try {
    entrypoints[path.basename(p)] = require.resolve(path.resolve(p));
  } catch (e) {}
  return entrypoints;
}, {});

module.exports = {
  resolve: {
    root: [
      APP_MODULES_DIR,
      LIB_MODULES_DIR,
    ],
  },
  module: {
    loaders: [
      {test: /\.s(c|a)ss$/, loader: 'style!css!sass'}, // use ! to chain loaders
      {test: /\.css$/, loader: 'style!css'},
      {test: /\.(png|jpg)$/, loader: 'url?limit=8192'}, // inline base64 URLs for <=8k images, direct URLs for the rest
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
      {test: require.resolve("react"), loader: "expose?React"},
    ]
  }
};