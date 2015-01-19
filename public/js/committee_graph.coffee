class CommitteeGraph
  constructor: () ->

  initialize: (element, data, options) ->
    console.log("Initializing Committee Graph")
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
    @activeFilters   = []
    @graph           = Viva.Graph.graph();
    @graphParameters = {
      graphics :  @defaultGraphics()
      layout   :  @defaultLayout()
    }
    return

  defaultGraphics: () =>
    graphics = Viva.Graph.View.svgGraphics()
    graphics.node (node) ->
      ui = Viva.Graph.svg('g')

      svgText = Viva.Graph.svg('text').
      attr('font-size', "18px").
      attr('text-anchor','middle').
      attr('y',(-17)).
      text(node.id)

      img = Viva.Graph.svg('circle').
      attr('r', node.data.size).
      attr('fill', node.data.fillColor).
      attr('stroke', '#000')

      ui.append(img)
      ui.append(svgText)

      return ui

    .placeNode((nodeUI, pos) ->
      nodeUI.attr('transform', 'translate(' + (pos.x) + ',' + (pos.y) + ')')
    )
    return graphics

  defaultLayout: () =>
    layout   = Viva.Graph.Layout.forceDirected(@graph,
      springTransform:  (link, spring) ->
        if link.data is 1
          spring.coeff = 0.00003
          spring.length = 350
          spring.weight = 2
        else if link.data is 2
          spring.length = 300
          spring.coeff = 0.0003
        gravity: -10
    )

    return layout

  #Updates graph
  updateGraph: () =>

  #Adds a node to the graph
  addNode: ()=>

  #Adds a link to the graph
  addLink: () =>

  randomNum: () ->
    return Math.floor(Math.random() * max)

###
  Displays all Ithaca College employees that are in a specific committee based off of the
  parameters
###
class EmployeeGraph extends Graph
  constructor:() ->
    super
    renderer = Viva.Graph.View.renderer(@graph, {
      container : document.getElementById(@options.container)
      graphics  : @graphParameters.graphics
      layout    : @graphParameters.layout
      prerender : true
    });

    svgElement = @graphParameters.graphics.getSvgRoot()
    svgElement.attr('class','employee_visualization')
    $(svgElement).bind( 'mousewheel DOMMouseScroll', (e) ->
      if e.shiftKey isnt true
        e.preventDefault()
        return false
    )
    renderer.run()

  updateGraph: (members) =>
    memberNames = []
    for member in members
      memberNames.push(member.name)

    @graph.forEachNode( (node) =>
      if (node.id not in memberNames) then @graph.removeNode(node.id)
      return
    )

    for member in members
      @addNode(member,"user")
      for workInfo in member.workInfo
        if workInfo.location.indexOf("School") > -1
          if member.workInfo.length == 1
            if @graph.getNode(workInfo.location) is undefined then @addNode(workInfo,"school")
            @graph.addLink(member.name,workInfo.location,1)
        else
          @addNode(workInfo,"department")
          @graph.addLink(member.name,workInfo.location,1)
          #Find out which school department is in
          for school,vals of @schools
            for department in @schools[school].departments
              if department is workInfo.location
                if @graph.getNode(school) is undefined then @addNode({location:school},"school")
                @graph.addLink(workInfo.location,school,2)


    #TODO: Add more user details to addnode. Also possibly add more details to locations



  addNode: (nodeData,type)=>
    if type is "user"
      @graph.addNode(nodeData.name,
        fillColor: "black"
        size: "12"
      )
    else if type is "department"
      @graph.addNode(nodeData.location,
        fillColor: "blue"
        size:"14"
      )
    else if type is "school"
      @graph.addNode(nodeData.location,
        fillColor: "green"
        size:"18"
      )


class LocationGraph extends Graph
  constructor:() ->
    super
    renderer = Viva.Graph.View.renderer(@graph, {
      container : document.getElementById(@options.container)
      graphics  : @graphParameters.graphics
      layout    : @graphParameters.layout
      prerender :true
    });
    renderer.run()

class PositionGraph extends Graph
  constructor:() ->
    super
    renderer = Viva.Graph.View.renderer(@graph, {
      container : document.getElementById(@options.container)
      graphics  : @graphParameters.graphics
      layout    : @graphParameters.layout
      prerender :true
    });
    renderer.run()


exports = this
exports.CommitteeGraph = new CommitteeGraph()