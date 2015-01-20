module.exports.start = function () {
  var graph = require('ngraph.graph')();
  var createPixiGraphics = require('ngraph.pixi');

  var pixiGraphics = createPixiGraphics(graph,
      {
        physics: {
          springLength: 300,
          springCoeff: 0.0003,
          dragCoeff: 0.01,
          gravity: -1.2
  }
      });

  // setup our custom looking nodes and links:
  pixiGraphics.createNodeUI(require('./lib/createNodeUI'))
    .renderNode(require('./lib/renderNode'))
    .createLinkUI(require('./lib/createLinkUI'))
    .renderLink(require('./lib/renderLink'));



  return {
    graph    : graph,
    graphics : pixiGraphics
  }
}
