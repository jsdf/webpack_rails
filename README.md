# webpack_rails
Minimally integrates Webpack with Rails/Sprockets

While working towards the ultimate goal of transitioning off of Sprockets entirely,
this gem handles spawning a webpack process or dev server before any assets are
resolved.

Additionally:

- When not using the dev server, it also ensures the assets have been 
built before they are consumed by Sprockets.
- When using the dev server, it adds hot module replacement support.

## Quickstart

```bash
# in your rails root
npm init
# install required dependencies
npm install --save webpack webpack-dev-middleware
# optionally install loaders for various file types
npm install --save babel-loader sass-loader css-loader style-loader
```

Create a webpack config file at `config/webpack.config.js` (configurable).

```js
// config/webpack.config.js
var webpack = require('webpack');

module.exports = {
  // set up entrypoints in the usual webpack way
  entry: 'app/client/main.js',
  output: {
    // output filenames must end in .bundle.js (.bundle.css for ExtractTextPlugin)
    filename: '[name].bundle.js',
    // if using sprockets, you'll want to output bundles somewhere temporary
    // otherwise, you might want to output to somewhere in `/public`
    path: './tmp/webpack/bundles',
  },
  // configure some loaders
  module: {
    loaders: [
      {test: /\.scss$/, loader: 'style!css!sass'},
      {test: /\.js$/, exclude: /node_modules/, loader: 'babel'},
    ],
  },
};
```

If you're using Sprockets to post-process the assets, you'll want to add your bundle
output directory to the sprockets asset path.
```ruby
# application.rb

config.assets.paths << Rails.root.join('tmp/webpack/bundles') # should be the same as your webpack output.path config
```

You can provide configuration with the `config.webpack_rails` object:

```ruby
# application.rb
config.webpack_rails.webpack_config_file = 'config/webpack.config.js' # default
```

When developing locally the `dev_server` mode is recommended, which seamlessly rebuilds bundles as required and provides hot module replacement.

```ruby
# development.rb
config.webpack_rails.dev_server = true # use webpack dev server with hot module replacement
config.webpack_rails.port = 9001 # port to run dev server on
config.webpack_rails.host = 'localhost' # ip to bind dev server on
```

Alternatively, you can just run webpack in 'watch' mode:

```ruby
# development.rb
config.webpack_rails.watch = true
```

When referencing bundles, eg. in `javascript_include_tag` or `stylesheet_link_tag`, use the
`webpack_bundle_asset` helper so that in `dev_server` mode, the asset is loaded
from the webpack dev server, and otherwise is resolved as a regular asset. Don't forget to
add your webpack output path to Sprockets, if you're using it.

```erb
= javascript_include_tag webpack_bundle_asset('app.bundle.js')
= stylesheet_link_tag webpack_bundle_asset('app.bundle.css'), media: 'screen, print'
```

Finally, in production you can just run `assets:precompile` and webpack will automatically run before assets are precompiled.

### Passing configuration through to webpack config

You can set environment variables which will be passed through to the webpack process (which the webpack config file is run in):

```ruby
# production.rb

config.webpack_rails.env['WEBPACK_CONFIG_OPTIMIZE'] = 'true'
```

Then you can access these environment variables from your webpack config file:

```js
// your webpack config
module.exports = {
  //...
};

if (process.env.WEBPACK_CONFIG_OPTIMIZE) {
  module.exports.plugins.push(new webpack.optimize.UglifyJsPlugin());
}
```

### Output CSS to a file

When in `dev_server` mode, you'll want to use style-loader so CSS is included with the JS. However, in the production environment you'll want to use ExtractTextPlugin to output real CSS files instead.

You can switch loaders in your webpack config file based on environment variables:

```js
var cssLoader = {
  test: /\.scss$/,
  loader: 'css-loader!sass-loader',
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

You can then set the `WEBPACK_CONFIG_EXTRACT_CSS` environment variable in your `production.rb`:
```ruby
# production.rb

config.webpack_rails.env['WEBPACK_CONFIG_EXTRACT_CSS'] = 'true'
```

Finally, you can include the output CSS file on a page by calling `webpack_bundle_asset`:

```
= stylesheet_link_tag webpack_bundle_asset('app.bundle.css'), media: 'screen, print'
```
