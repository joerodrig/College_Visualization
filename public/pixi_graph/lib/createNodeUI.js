module.exports = function (node) {
  return new AnimatedNode(node);
}

function AnimatedNode(node) {
  var type = node.data.type;
  if (type === "user"){
    this.color = "0x10100F";
    this.width = 8;

  }
  else if (type === "department"){
    this.color = "0x1E703B";
    this.width = 15;
  }
  else if (type === "school"){
    this.color = "0x297DB5";
    this.width = 25;
  }
}


