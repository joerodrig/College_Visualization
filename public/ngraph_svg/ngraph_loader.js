module.exports.start = function () {
  var graph = require('ngraph.graph')();
  var svg = require('simplesvg');

    var renderer = require('ngraph.svg')(graph, {
        physics: {
            springLength: 325
        }
    });

  return {
      graph    : graph,
      renderer : renderer,
      svg      : svg
  }
};
