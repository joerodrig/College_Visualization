module.exports = function (nodeProperties, ctx) {
  //nodeProperties.renderFrame();
  ctx.lineStyle(0);
  ctx.beginFill(nodeProperties.color,1);
  ctx.drawCircle(nodeProperties.pos.x, nodeProperties.pos.y, nodeProperties.width);
}
