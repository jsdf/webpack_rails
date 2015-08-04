# webpack_rails
Integrates Webpack with Rails/Sprockets

## quickstart

```bash
# in your rails root
npm init
# install required dependencies
npm install --save webpack glob
# optionally install loaders for various file types
npm install --save babel-loader coffee-loader cjsx-loader image-loader css-loader sass-loader less-loader
```

Create a webpack config file in Rails `config/` directory:

```js
// config/webpack.config.js
var path = require('path');
var glob = require('glob');
var webpack = require('webpack');

// feel free to change any of the paths in this file to suit your 
// desired directory structure. this file shows one possible structure 
// you can use.
// in this example, all the files in `app/client/entrypoints` are 
// entrypoints to webpack bundles which will be built. if you had a file
// `app/client/entrypoints/users.js` it would result in a `users.bundle.js` output file.
var entrypoints = glob.sync('app/client/entrypoints/*/').reduce(function(entries, p) {
  entries[path.basename(p)] = path.resolve(p);
  return entries;
}, {});

module.exports = {
  entry: entrypoints,
  output: {
    filename: '[name].bundle.js',
    // webpack must output bundles here to be consumed by rails asset pipeline
    path: './tmp/webpack',
    // required for asset urls to be rewritten by rails asset pipeline
    publicPath: '$asset_root/',
  },
  resolve: {
    root: [
      // application modules can live in app/client/modules
      // shared modules can live in lib/client/modules
      path.resolve('./app/client/modules'),
      path.resolve('lib/client/modules'),
    ],
  },
  plugins: [
    // uncomment this to factor out common dependencies into a single bundle
    // new webpack.optimize.CommonsChunkPlugin('common.bundle.js'),
  ],
  module: {
    loaders: [
      {test: /\.s(c|a)ss$/, loader: 'style!css!sass'},
      {test: /\.less$/, loader: 'style!css!less'},
      {test: /\.css$/, loader: 'style!css'},
      {test: /\.(png|jpg)$/, loader: 'url?limit=8192'},
      {test: /\.coffee$/, loader: 'coffee'},
      {test: /\.cjsx/, loader: 'cjsx'},
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel',
      },
    ]
  }
};
```

You can use the bundled webpack output just as with any other Rails assets.

In a normal Rails asset file:

```
// in application.js
//= require common.bundle.js
```

```
/*
 * in application.css
 *= require common.bundle.css
*/
```

Via Rails helpers:

```
<%= stylesheet_link_tag 'users.bundle.css` %>
<%= javascript_include_tag 'users.bundle.js` %>
```

![Under Construction](https://jamesfriend.com.au/files/under-construction.gif)
