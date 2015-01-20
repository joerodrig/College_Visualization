module.exports.start = function () {

// create an new instance of a pixi stage
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
      .renderLink(require('./lib/renderLink'))
      .stage.setBackgroundColor("0xFFFFFF");

 // var background =  PIXI.Sprite.fromImage("../img/noisy_texture.png");
  //pixiGraphics.stage.addChild(background);





  return {
    graph    : graph,
    graphics : pixiGraphics
  }
}
