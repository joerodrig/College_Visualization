module.exports.start = (listeners) ->
  graph = require("ngraph.graph")()
  svg = require("simplesvg")
  renderer = require("ngraph.svg")(graph,
    physics:
      springLength: 500
      springCoeff: 0.0008
      gravity: -10
      theta: .8
      dragCoeff: 0.005,
      timeStep:20

  )


  renderer.node((node) =>
    svg = svg
    ui = svg('g')

    circ = svg("circle")
    .attr('fill', node.data.fill)
    .attr('r', node.data.size)
    .attr('class', node.data.type)

    txt = svg('text').
    attr('font-size', "18px").
    attr('text-anchor', 'middle').
    attr('y', parseInt("-" + node.data.size + (-17))).
    attr('class', node.data.type + "_label")
    txt.textContent = node.id

    ui.append(circ)
    ui.append(txt)

    if node.data.type is "school_node"
      $(circ).click((e) =>
        if e.shiftKey is true then  listeners.schoolClicked(node.id)
      )
    else if node.data.type is "department_node"
      $(circ).click((e) =>
        if e.shiftKey is true then listeners.departmentClicked(node.id)
      )


    return ui
  )
  .placeNode((nodeUI, pos) ->
    nodeUI.attr('transform', 'translate(' + (pos.x) + ',' + (pos.y) + ')')
  )

  renderer.link((link) =>
    console.log(link)

    return svg("line").attr("stroke", "#000")

  )


  console.log(renderer)
  return {
  graph: graph
  renderer: renderer
  svg: svg
  }