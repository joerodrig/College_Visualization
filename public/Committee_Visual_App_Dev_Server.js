/*
Basic Express Server for Devevelopment Testing on local machine

 */
var express = require('express');
var app     = express();
var path    = require('path');

app.use(express.static(__dirname)); // Current directory is root

app.listen(8081,"localhost");
console.log('Listening on port 8081');
