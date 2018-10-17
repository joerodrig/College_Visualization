var express = require('express');
var app = express();
var path = require('path');

app.use(express.static('public'))

app.get('/', function(req,res){
  res.render('index');
});

app.listen(process.env.PORT || 4000);
console.log ('server is running');
