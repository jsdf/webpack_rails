# webpack_rails
Integrates Webpack with Rails/Sprockets

The main rationale of this approach is to keep things working relatively seamlessly and automatically alongside existing Sprockets-based code, and meeting the developer-experience expectations of Rails developers, while working towards the ultimate goal of transitioning off of Sprockets entirely.

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
    // webpack must output bundles here
    path: './tmp/webpack',
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
from the webpack dev server, and otherwise is resolved as a regular asset.

```erb
= javascript_include_tag webpack_bundle_asset('app.bundle.js')
= stylesheet_link_tag webpack_bundle_asset('app.bundle.css'), media: 'screen, print'
```

### Sprockets integration

While transitioning your codebase away from Sprockets, you can include the bundled 
webpack output in a normal Sprockets asset file via the `webpack_require` directive:

```js
// in application.js
//= webpack_require posts.bundle.js
```

Finally, in production you can just run `assets:precompile` and webpack will automatically run before assets are precompiled.

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
ENV['WEBPACK_CONFIG_EXTRACT_CSS'] = 'true'
```

Include the output file into a Sprockets CSS file using `webpack_require`. When using the dev server, this will not output anything, otherwise it will require the CSS output in the usual way.
```css
/*
 * in application.css
 *= webpack_require posts.bundle.css
*/
```

### app code package directories

You can configure one or more directories for 'packages' of your application code which can be required by package name, like those in the node_modules directory:
```js
module.exports = {
  // ...
  resolve: {
    root: [
      // application modules can live in app/client/modules
      path.resolve('app/client/modules'),
    ],
  },
};
```

### automatically find all entrypoint files in a directory

In this example, all the files in `app/client/entrypoints` are entrypoints to webpack 
bundles which will be built. if you had a file `app/client/entrypoints/users.js` it 
would result in a `users.bundle.js` output file.

```js
var glob = require('glob');
var path = require('path');

var entrypoints = glob.sync('app/client/entrypoints/*/').reduce(function(entries, p) {
  entries[path.basename(p)] = path.resolve(p);
  return entries;
}, {});

module.exports = {
  entry: entrypoints,
  // ...
};
```

### require media assets from webpack js/css

```js
// config/webpack.config.js
var webpack = require('webpack');

module.exports = {
  // ...
  output: {
    // ...
    // required for asset urls (eg. images) to be rewritten by Sprockets' asset_path helper
    publicPath: '$asset_root/',
  },
  module: {
    loaders: [
      //...
      // enable requiring images from css/js.
      // this will copy files to a path inside the directory specified by the 
      // webpack `output.path` setting, eg. './tmp/webpack/bundles', and in the source 
      // they will be referred to as as their location inside that directory, prefixed
      // by the webpack `output.publicPath` setting, '$asset_path/'.
      // WebpackRails::Processor will rewrite strings starting with '$asset_path'
      // using the Sprockets asset_path helper, so Sprockets can resolve those 
      // files and digest them etc. in the usual Rails Asset Pipeline way.
      // https://github.com/webpack/file-loader
      {
        test: /\.(png|jpg|gif)$/,
        loader: 'file-loader',
        query: {
          name: '[path][name].[ext]',
        },
      },
    ],
  },
};
```

Used in production at [Culture Amp](https://www.cultureamp.com/)
