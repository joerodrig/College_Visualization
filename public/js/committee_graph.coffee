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
    createdGraph     = new ngraph.start()
    @activeFilters   = []
    @graph           = createdGraph.graph
    @graphParameters =  {
      graphics : createdGraph.graphics
    }

    @graphParameters.graphics.run()
    return

###
  Displays all Ithaca College employees that are in a specific committee based off of the
  parameters
###
class EmployeeGraph extends Graph
  constructor:() ->
    super
    graphElement = @graphParameters.graphics.domContainer
    $(graphElement).attr('class','employee_visualization')
    $(graphElement).detach()
    $('#demo').append(graphElement)
    @graphParameters.graphics.run()

  updateGraph: (members) =>
    memberNames = []
    for member in members
      memberNames.push(member.name)

    @graph.forEachNode( (node) =>
      if (node.id not in memberNames) then @graph.removeNode(node.id)
      return
    )

    for member in members
      @addNode(member.name,"user")
      for workInfo in member.workInfo
        if workInfo.location.indexOf("School") > -1
          if member.workInfo.length == 1
            if @graph.getNode(workInfo.location) is undefined then @addNode(workInfo.location,"school")
            @graph.addLink(member.name,workInfo.location,1)
        else
          @addNode(workInfo.location,"department")
          @graph.addLink(member.name,workInfo.location,1)
          #Find out which school department is in
          for school,vals of @schools
            for department in @schools[school].departments
              if department is workInfo.location
                if @graph.getNode(school) is undefined then @addNode(school,"school")
                @graph.addLink(workInfo.location,school,2)


    #TODO: Add more user details to addnode. Also possibly add more details to locations

  addNode: (nodeID,type)=>
    @graph.addNode(nodeID,
     type : type
    )
    return

class LocationGraph extends Graph
  constructor:() ->
    super

class PositionGraph extends Graph
  constructor:() ->
    super




exports = this
exports.CommitteeGraph = new CommitteeGraph()