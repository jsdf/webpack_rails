var stripAnsi = require('strip-ansi');
var jsStringEscape = require('js-string-escape');

// webpack is expected to be installed by the gem consumer (eg. the app)
var RawSource = require('webpack/lib/RawSource');

var errorTypePattern = /ModuleBuildError:[^:]*: /g;

// a webpack plugin to inject js which renders a message upon error
function ErrorMessagePlugin() {}
ErrorMessagePlugin.prototype.apply = function(compiler) {
  // if there are errors, replace the output of any bundles with an error message
  compiler.plugin('emit', function(compilation, done) {
    if (compilation.errors.length > 0) {
      var errorJsCode = renderErrorJsCode(compilation.errors);

      Object.keys(compilation.assets)
        .filter(isABundle) // don't mess with hot-update assets
        .forEach(function(assetName) {
          compilation.assets[assetName] = new RawSource(errorJsCode);
        });
    }

    done();
  }.bind(this));
};

function isABundle(assetName) {
  return /\.bundle\./.test(assetName);
}

function renderErrorJsCode(errors) {
  var cleanedErrorMessage = cleanCompilationErrorMessages(errors);
  var errorPageHeader = ''+
    '<style>body { font-family: sans-serif; }</style>'+
    '<h1>Webpack Build Error</h1>';

  var errorJsCode = ''+
    'document.body.className += " webpack-build-error";'+
    'document.body.innerHTML = "'+errorPageHeader+'";\n'+
    'var errorDisplay = document.createElement("pre");\n'+
    'errorDisplay.textContent = "'+jsStringEscape(cleanedErrorMessage)+'";\n'+
    'document.body.appendChild(errorDisplay);\n';

  return errorJsCode;
}

function cleanCompilationErrorMessages(errors) {
  return stripAnsi(errors.join('\n\n')).replace(errorTypePattern, '');
}

module.exports = ErrorMessagePlugin;
