module.exports = varta;

module.exports.has = delayedVerify;

function varta(suspect, name) {
  name = name || 'Argument';

  return {
    has: has
  };

  function has() {
    return internalVerify(suspect, name, arguments);
  }
}

function delayedVerify() {
  var expectations = arguments;
  return verify;

  function verify(suspect, name) {
    return internalVerify(suspect, name, expectations);
  }
}

function internalVerify(suspect, name, expectations) {
  if (suspect === undefined) {
    throw new Error(name + ' is not defined');
  }

  for (var i = 0; i < expectations.length; ++i) {
    if (suspect[expectations[i]] === undefined) {
      throw new Error(name + ' is expected to have a property `' + expectations[i] + '`');
    }
  }

  return true;
}
