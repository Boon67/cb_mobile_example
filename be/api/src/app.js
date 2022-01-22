var express = require('express');
var logger = require('morgan');
require('dotenv').config()
const db = require('./db/couchbase');
const bodyParser = require('body-parser')
const port = process.env.API_PORT || 3001;
const Routes = require('./routes/routes');

var app = express();

// app configurations
app.set('port', port);

// load app middlewares
app.use(logger('dev'));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

const dbURI = process.env.dbURI;

/*
couchbase
	.connect(dbURI, {
		useNewUrlParser: true,
		useCreateIndex: true,
		useUnifiedTopology: true,
	})
	.then(() => console.log("Database Connected"))
	.catch((err) => console.log(err));

couchbase.Promise = global.Promise;
*/

// load our API routes
app.use('/', Routes);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  res.status(err.status || 404).json({
    message: "No such route exists"
  })
});

// error handler
app.use(function(err, req, res, next) {
  res.status(err.status || 500).json({
    message: "Error Message"
  })
});

// app configurations
app.set('port', port);

// establish http server connection
app.listen(port, () => { console.log(`App running on port ${port}`) });

module.exports = app;
