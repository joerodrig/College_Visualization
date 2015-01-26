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
      userClicked       : data.userClicked

    employeeGraph = new EmployeeGraph(data,clickListeners,options)
    return {
      updateGraph: (nodes,adding) =>
        employeeGraph.updateGraph(nodes,adding)
      }


class Graph
  constructor: (@schoolInfo,listeners,@options) ->
    createdGraph     = new ngraph.start(listeners)
    @activeFilters   = []
    @graph           = createdGraph.graph
    @graphParameters =  {
      renderer: createdGraph.renderer
      svg     : createdGraph.svg
    }
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


  pinNode: (node) =>
    console.log(@graph.getNode(node))
    @graphParameters.renderer.layout.pinNode(@graph.getNode(node),true)


  initial: () =>
    totalDepartments = 0

    for school,properties of @schoolInfo.schools
      totalDepartments += properties.departments.length
    mainNode = {id:"Ithaca College",type:"main" , size:totalDepartments}
    @graphParameters.renderer.layout.pinNode(@addNode(mainNode),true)
    for school,properties of @schoolInfo.schools
      schoolNode = {id:school,type:properties.type,size:properties.departments.length}
      @addNode(schoolNode)
      @graph.addLink(schoolNode.id,mainNode.id,schoolNode.size)



  updateGraph: (primaryNode,adding) =>
    if primaryNode.type is "school"
      for departmentName,properties of primaryNode.standardizedDepartments
        @toggleLinks(primaryNode,properties,adding)

    if primaryNode.type is "department"
      for username,properties of primaryNode.standardizedUsers
        @toggleLinks(primaryNode,properties,adding)

    if primaryNode.type is "committee_links"
      previous = null
      index = 0
      while index < primaryNode.members.length
        if primaryNode.members[index+1] isnt undefined and adding
          @graph.addLink(primaryNode.members[index],primaryNode.members[index+1],999)
        else if adding is not true
          @graph.removeLink(@graph.hasLink(primaryNode.members[index],primaryNode.members[index+1]))
        index++


  addNode: (node)=>
    if @graph.getNode(node.id) is undefined
      if node.type is "user"
        @graph.addNode(node.id,
          fill: node.fill
          size: "10"
          textSize:"16px"
          type:"user_node"
        )
      else if node.type is "department"
        @graph.addNode(node.id,
          fill: node.fill
          size: node.size
          textSize:"18px"
          type: "department_node"
        )

      else if node.type is "school"
        if node.size < 14
          node.size = 14
        else if node.size > 25
          node.size  = 25

        @graph.addNode(node.id,
          fill: "#bbeeff"
          size: node.size*2
          textSize:"38px"
          type:"school_node")

      else if node.type is "main"
        @graph.addNode(node.id,
        fill: "#0055bb"
        size: node.size
        textSize: "38px"
        type:"main_node"
        )

  toggleLinks:(from,to,adding) =>
    if adding
      @addNode(to)
      @addLink(from.id,to.id,2)
    else
      @removeLink(from.id,to.id)

  removeLink: (fromID,toID) =>
    @graph.removeLink(@graph.hasLink(fromID,toID))
    if @graph.getLinks(toID).length < 1
      @graph.removeNode(toID)

  addLink: (from,to,strength) =>
    hasLink = @graph.hasLink(from,to)
    if hasLink is null
      @graph.addLink(from,to,strength)



exports = this
exports.CommitteeGraph = new CommitteeGraph()