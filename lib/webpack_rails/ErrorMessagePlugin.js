var stripAnsi = require('strip-ansi');
var jsStringEscape = require('js-string-escape');

// expected to be installed by the gem consumer (eg. the app)
var RawSource = require('webpack/lib/RawSource');

// a webpack plugin to inject js which renders a message upon error
function ErrorMessagePlugin() {}
ErrorMessagePlugin.prototype.apply = function(compiler) {
  compiler.plugin('emit', function(compilation, callback) {
    if (compilation.errors.length > 0) {
      var cleanedErrorMessage = cleanCompilationErrorMessages(compilation.errors);
      var errorPageHeader = ''+
        '<style>body { font-family: sans-serif; }</style>'+
        '<h1>Webpack Build Error</h1>';

      var errorJsCode = ''+
        'document.body.className += " webpack-build-error";'+
        'document.body.innerHTML = "'+errorPageHeader+'";\n'+
        'var errorDisplay = document.createElement("pre");\n'+
        'errorDisplay.textContent = "'+jsStringEscape(cleanedErrorMessage)+'";\n'+
        'document.body.appendChild(errorDisplay);\n';

      Object.keys(compilation.assets).forEach(function(assetName) {
        compilation.assets[assetName] = new RawSource(errorJsCode)
      });
    }
    callback();
  }.bind(this));
};

var errorTypePattern = /ModuleBuildError:[^:]*: /g;
function cleanCompilationErrorMessages(errors) {
  return stripAnsi(errors.join('\n\n')).replace(errorTypePattern, '');
}

module.exports = ErrorMessagePlugin;
