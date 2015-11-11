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
  var errorMessages = errors.map(formatError);
  return stripAnsi(errorMessages.join('\n\n')).replace(errorTypePattern, '');
}

// from webpack/lib/Stats.js
function formatError(e) {
  var requestShortener = {
    shorten: function(request) { return request; },
  };
  var showErrorDetails = true;
  var text = "";
  if(typeof e === "string")
    e = {
      message: e
    };
  if(e.chunk) {
    text += "chunk " + (e.chunk.name || e.chunk.id) +
      (e.chunk.entry ? " [entry]" : e.chunk.initial ? " [initial]" : "") + "\n";
  }
  if(e.file) {
    text += e.file + "\n";
  }
  if(e.module && e.module.readableIdentifier && typeof e.module.readableIdentifier === "function") {
    text += e.module.readableIdentifier(requestShortener) + "\n";
  }
  text += e.message;
  if(showErrorDetails && e.details) text += "\n" + e.details;
  if(showErrorDetails && e.missing) text += e.missing.map(function(item) {
    return "\n[" + item + "]";
  }).join("");
  if(e.dependencies && e.origin) {
    text += "\n @ " + e.origin.readableIdentifier(requestShortener);
    e.dependencies.forEach(function(dep) {
      if(!dep.loc) return;
      if(typeof dep.loc === "string") return;
      if(!dep.loc.start) return;
      if(!dep.loc.end) return;
      text += " " + dep.loc.start.line + ":" + dep.loc.start.column + "-" +
        (dep.loc.start.line !== dep.loc.end.line ? dep.loc.end.line + ":" : "") + dep.loc.end.column;
    });
  }
  return text;
}

module.exports = ErrorMessagePlugin;
