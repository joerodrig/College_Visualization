# varta

Guard your arguments. Verify and throw error if they do not meet your contract

[![build status](https://secure.travis-ci.org/anvaka/varta.png)](http://travis-ci.org/anvaka/varta)

# usage

``` javascript
var guard = require('varta');

function log(logger) {
  // this line will throw exception if logger instance is null or doesn't have
  // a method called `log`:
  guard(logger).has('log');
}
```

You can also expect multiple properties from an object:

``` javascript
var guard = require('varta');

function log(logger) {
  // this line will throw exception if logger instance is null or doesn't have
  // all three methods: `warn`, `info`, and `debug`
  guard(logger).has('warn', 'info', 'debug');
}
```

You can save expectations and reuse them in the code:

``` javascript
var verify = require('varta').has('warn', 'info', 'debug');

function log(logger) {
  // Our expectations are saved above. If the logger does not have all three
  // methods (`warn`, `info`, and `debug`) the code will throw an exception
  verify(logger);
}
```

# why?

Failing early is very helpful technique when it comes to maintaining large
code bases. If you fail as early as possible you will know exactly where something
went wrong, instead of debugging a cryptic error message down the stack.

# install

With [npm](https://npmjs.org) do:

```
npm install varta
```

# license

MIT
