var express = require('express');
var app = express();
var path = require('path');

app.use(express.static(__dirname,{maxAge:3155760000})); // Current directory is root

app.listen(8081,"localhost");
console.log('Listening on port 8081');
