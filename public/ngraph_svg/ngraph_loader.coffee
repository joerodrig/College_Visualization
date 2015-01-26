module.exports.start = (listeners) ->
  graph = require("ngraph.graph")()
  svg = require("simplesvg")
  renderer = require("ngraph.svg")(graph,
    physics:
      springLength: 325
      springCoeff: 0.000008
      gravity: -5
      theta: 1
      dragCoeff: 0.005,
      timeStep:50
      springTransform:(link, spring) ->
                      if link.toId is "Ithaca College"
                        spring.length = 450 + link.data*3
                        spring.weight = 0.5
  )

  renderer.node((node) =>
    svg = svg
    ui = svg('g')

    circ = svg("circle")
    .attr('fill', node.data.fill)
    .attr('r', node.data.size)
    .attr('class', node.data.type)

    txt = svg('text').
    attr('font-size', node.data.textSize).
    attr('text-anchor', 'middle').
    attr('y', parseInt("-" + node.data.size + (-18))).
    attr('class', node.data.type + "_label")
    txt.textContent = node.id

    ui.append(circ)
    ui.append(txt)

    if node.data.type is "school_node"
      $(circ).click((e) =>
        if e.shiftKey is true then listeners.schoolClicked(node.id)
      )
    else if node.data.type is "department_node"
      $(circ).click((e) =>
        if e.shiftKey is true then listeners.departmentClicked(node.id)
      )
    else if node.data.type is "user_node"
      $(circ).click((e) =>
        if e.shiftKey is true then listeners.userClicked(node.id)
      )
    return ui
  )
  .placeNode((nodeUI, pos) ->
    nodeUI.attr('transform', 'translate(' + (pos.x) + ',' + (pos.y) + ')')
  )

  renderer.link((link) =>
    return svg("line").attr("stroke", "#000")
  )



  return {
  graph: graph
  renderer: renderer
  svg: svg
  }