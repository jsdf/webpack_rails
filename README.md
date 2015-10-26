# webpack_rails
Integrates Webpack with Rails/Sprockets

## quickstart

```bash
# in your rails root
npm init
# install required dependencies
npm install --save webpack webpack-dev-middleware
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

You can use the bundled webpack output via the `webpack_require` directive.

In a normal Rails asset file:

```
// in application.js
//= webpack_require posts.bundle.js
```

You can also use ExtractTextPlugin to output css files. In this case you should 
include them using `webpack_require`. 
```
/*
 * in application.css
 *= webpack_require posts.bundle.css
*/
```

To make use of HMR, you might want to configure css to be output using style-loader
the development environment, but use ExtractTextPlugin in the production environment.

As any environment variables set in the Rails application will be passed through 
to your webpack config file, you can do something like this:

```js
var cssLoader = {
  test: /\.css$/,
  loader: 'css-loader?modules',
}

// your webpack config
var config = {
  module: {
    loaders: [
      cssLoader,
    ]
  }
};

if (process.env.WEBPACK_CONFIG_EXTRACT_CSS) {
  config.plugins.push(
    // ExtractTextPlugin is used to output the css to css files rather than 
    // outputting js which creates script tags (which is what style-loader does 
    // by default)
    // https://github.com/webpack/extract-text-webpack-plugin
    new ExtractTextPlugin(
      '[name].bundle.css' // css requires are extracted and combined into a css bundle
    )
  );
  // enhance cssLoader entry to use ExtractTextPlugin.extract loader
  cssLoader.loader = ExtractTextPlugin.extract('style-loader', cssLoader.loader);
} else {
  // enhance cssLoader entry to use style loader
  cssLoader.loader = 'style-loader!' + loaderEntry.loader;
}
```

Then in production.rb
```ruby
ENV['WEBPACK_CONFIG_EXTRACT_CSS'] = 'true'
```

![Under Construction](https://jamesfriend.com.au/files/under-construction.gif)
