class CommitteeGraph
  constructor: () ->

  initialize: (element, data, options) ->
    return new cGraph(element, data, options)

class cGraph
  constructor: (element, data, options) ->
    return controller = new Controller(data, options)


class Controller
  constructor: (data, options) ->
    employeeGraph = new EmployeeGraph(data.schoolLinker,options)
    return {
    updateGraph: (members) =>
      employeeGraph.updateGraph(members)
    }


class Graph
  constructor: (@schools,@options) ->
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

      txt = svg('text').
      attr('font-size', "18px").
      attr('text-anchor','middle').
      attr('y',(-17))
      txt.textContent = node.id

      ui.append(circ)
      ui.append(txt)

      return ui
    )
    .placeNode((nodeUI, pos) ->
      nodeUI.attr('transform', 'translate(' + (pos.x) + ',' + (pos.y) + ')')
    )
    return

    @graphParameters.renderer.layout.simulator.gravity(-5)

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

  updateGraph: (members) =>
    memberNames = []
    for member in members
      memberNames.push(member.name)

    @graph.forEachNode( (node) =>
      if (node.id not in memberNames) then @graph.removeNode(node.id)
      return
    )

    for member in members
      @addNode(member.name,"un")
      for workInfo in member.workInfo
        if workInfo.location.indexOf("School") > -1
          if member.workInfo.length == 1
            if @graph.getNode(workInfo.location) is undefined then @addNode(workInfo.location,"sn")
            @graph.addLink(member.name,workInfo.location,1)
        else
          @addNode(workInfo.location,"dn")
          @graph.addLink(member.name,workInfo.location,1)
          #Find out which school department is in
          for school,vals of @schools
            for department in @schools[school].departments
              if department is workInfo.location
                if @graph.getNode(school) is undefined then @addNode(school,"sn")
                @graph.addLink(workInfo.location,school,2)


    #TODO: Add more user details to addnode. Also possibly add more details to locations

  addNode: (nodeID,type)=>
    if type is "un"
      @graph.addNode(nodeID,
        fill: "#000"
        size: "12"
      )
    else if type is "dn"
      @graph.addNode(nodeID,
        fill: "#FFF"
        size:"14"
      )
    else if type is "sn"
      @graph.addNode(nodeID,
        fill: "#a3ff00"
        size:"18"
      )
    return


exports = this
exports.CommitteeGraph = new CommitteeGraph()