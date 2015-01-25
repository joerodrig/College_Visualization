var test = require('tap').test;
var guard = require('../');

test('it checks properties', function(t) {
  var x = {};
  t.throws(function () { guard(x).has('foo'); }, 'x has no foo');

  var y = { foo: 0 };
  t.ok(guard(y).has('foo'), 'y has foo');

  t.throws(function () { guard(x).has('foo', 'bar'); }, 'y has no bar');

  var z = { foo: 0, bar: null };
  t.ok(guard(z).has('foo', 'bar'), 'y has foo');

  t.end();
});

test('it can save checks', function(t) {
  var verify = guard.has('foo', 'bar');

  var x = {};
  t.throws(function () { verify(x); }, 'x has no foo and bar');

  var y = { foo: 0, bar: 0 };
  t.ok(verify(y), 'y is good');

  t.end();
});
