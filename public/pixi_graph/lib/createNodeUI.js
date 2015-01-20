module.exports = function (node) {
  return new AnimatedNode(node);
}

var colorLookup = [0x00FFFF, 0xFF5552];

function AnimatedNode(node) {

  var type = node.data.type;
  if (type === "user"){
    this.color = "0xFFFFFF";
    this.width = 5;
  }
  else if (type === "department"){
    this.color = "0x1E703B";
    this.width = 10;
  }
  else if (type === "school"){
    this.color = "0x1E4F70";
    this.width = 15;
  }

}


