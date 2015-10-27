var fs = require('fs');

var loggingToFile = Boolean(process.env.WEBPACK_TASK_LOGGING);

function logLine(message) {
  fs.appendFileSync('log/webpack-task.log', new Date()+' -- '+message+'\n');
}

function log(message) {
  if (loggingToFile) logLine(message);
}

function logErr(err) {
  logLine(err.toString()+' -- '+JSON.stringify(err.stack));
}

log.error = logErr;

module.exports = log;
