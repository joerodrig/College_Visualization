class CommitteeGraph
  constructor: () ->

  initialize: (element, data, options) ->
    return new cGraph(element, data, options)

class cGraph
  constructor: (element, data, options) ->
    return controller = new Controller(data, options)


class Controller
  constructor: (data, options) ->
    clickListeners =
      schoolClicked     : data.schoolClicked
      departmentClicked : data.departmentClicked

    employeeGraph = new EmployeeGraph(data.schoolLinker,clickListeners,options)
    return {
      updateGraph: (nodes,adding) =>
        employeeGraph.updateGraph(nodes,adding)
      }


class Graph
  constructor: (@schools,@clickListeners,@options) ->
    createdGraph     = new ngraph.start()
    @activeFilters   = []
    @graph           = createdGraph.graph
    @graphParameters =  {
      renderer: createdGraph.renderer
      svg     : createdGraph.svg
    }


    @graphParameters.renderer.node((node) =>
      svg = @graphParameters.svg
      ui = svg('g')

      circ = svg("circle")
      .attr('fill',node.data.fill)
      .attr('r',node.data.size)
      .attr('class',node.data.type)

      txt = svg('text').
      attr('font-size', "18px").
      attr('text-anchor','middle').
      attr('y',parseInt("-"+node.data.size + (-17)))
      txt.textContent = node.id

      ui.append(circ)
      ui.append(txt)

      if node.data.type is "school_node"
        $(circ).click(() =>
          @clickListeners.schoolClicked(node.id)
        )
      else if node.data.type is "department_node"
        $(circ).click(() =>
          @clickListeners.departmentClicked(node.id)
        )



      return ui
    )
    .placeNode((nodeUI, pos) ->
      nodeUI.attr('transform', 'translate(' + (pos.x) + ',' + (pos.y) + ')')
    )
    return

    @graphParameters.renderer.layout.simulator.gravity(-15)

    @graphParameters.renderer.link((link) =>
      return @graphParameters.svg("line").
      attr("stroke","#FFF")
    )

    ###
      springTransform:  (link, spring) ->
        if link.data is 1
          spring.coeff = 0.00003
          spring.length = 350
          spring.weight = 2
        else if link.data is 2
          spring.length = 300
          spring.coeff = 0.0003
    ###


    return

###
  Displays all Ithaca College employees that are in a specific committee based off of the
  parameters
###
class EmployeeGraph extends Graph
  constructor:() ->
    super
    graphElement = @graphParameters.renderer.svgRoot
    $(graphElement).attr('class','employee_visualization')
    $(graphElement).detach()
    $('#demo').append(graphElement)
    @graphParameters.renderer.run()
    @initial()

  initial: () =>

    @graphParameters.renderer.layout.pinNode(@addNode("IC","main"),true)
    for school of @schools
      @addNode(school,"sn")
      @graph.addLink(school,"IC")

  updateGraph: (nodes,adding) =>
    toLink = []
    for node in nodes
      node.toLink = []
      if node.type is "department"
        type      = "dn"
        strength  = 2
        node.toLink.push( node.school )
      else if node.type is "user"
        type      = "un"
        strength  = 1
        for work in node.workInfo
          if @graph.getNode(work.location) is undefined
            @addNode(work.location,"dn")
          if work.location.indexOf("School") isnt -1 #If a school
            if node.workInfo.length == 1 || work.location.indexOf("Dean") isnt -1
              #Add a link if the person is some sort of dean, or if that is the only link
              node.toLink.push(work.location)
          else
            node.toLink.push(work.location)

      if adding
        @addNode(node.id,type)
        for otherNode in node.toLink
          @graph.addLink(node.id,otherNode,strength)
      else
        #TODO: Need to implement a lot of checks here
        @graph.removeNode(node.id)


  addNode: (nodeID,type)=>
    if type is "un"
      @graph.addNode(nodeID,
        fill: "#000"
        size: "12"
        type:"user_node"
      )
    else if type is "dn"
      @graph.addNode(nodeID,
        fill: "#FFF"
        size:"14"
        type:"department_node"
      )
    else if type is "sn"
      @graph.addNode(nodeID,
        fill: "#a3ff00"
        size:"18"
        type:"school_node"
      )
    else if type is "main"
      @graph.addNode(nodeID,
      fill: "blue"
      size:"22"
      type:"main_node"
      )


exports = this
exports.CommitteeGraph = new CommitteeGraph()