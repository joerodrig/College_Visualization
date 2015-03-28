class CommitteeGraph
  constructor: () ->

  initialize: (element, data, options) ->
    return new cGraph(element, data, options)

class cGraph
  constructor: (element, data, options) ->
    return controller = new Controller(data, options)


class Controller
  constructor: (data, options) ->
    employeeGraph = new EmployeeGraph(data,options)
    return {
      updateGraph: (nodes,adding) =>
        employeeGraph.updateGraph(nodes,adding)
      pinNode: (node) =>
        employeeGraph.pinNode(node)
      }


class Graph
  constructor: (@schoolInfo,@options) ->
    createdGraph     = new ngraph.start()
    @activeFilters   = []
    @graph           = createdGraph.graph
    @graphParameters =  {
      renderer: createdGraph.renderer
      svg     : createdGraph.svg
    }

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
    $("#"+@options.container).append(graphElement)
    @graphParameters.renderer.run()
    @initial()
    @committeeLinks = []


  pinNode: (node) =>
    gNode = @graph.getNode(node)
    if @graphParameters.renderer.layout.isNodePinned(gNode) isnt true
      @graphParameters.renderer.layout.pinNode(@graph.getNode(node),true)
    else
      @graphParameters.renderer.layout.pinNode(@graph.getNode(node),false)

  initial: () =>
    totalDepartments = 0

    for school,properties of @schoolInfo.schools
      totalDepartments += properties.departments.length
    mainNode = {id:"Ithaca College",type:"main" , size:totalDepartments, fill: "#0055bb", textSize:"38px"}
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
      ###
      index = 0
      while index < primaryNode.members.length
        if primaryNode.members[index+1] isnt undefined and adding
          @graph.addLink(primaryNode.members[index],primaryNode.members[index+1],999)
        else if adding is not true
          @graph.removeLink(@graph.hasLink(primaryNode.members[index],primaryNode.members[index+1]))
        index++
      ###


  addNode: (node)=>
    if @graph.getNode(node.id) is undefined
      if node.type is "school"
        if node.size < 14
          node.size = 14
        else if node.size > 25
          node.size  = 25
        node.size = node.size *2

      @graph.addNode(node.id,
      fill: node.fill
      size: node.size
      textSize: node.textSize
      type:node.type+"_node"
      )
    else
      @updateNodeAttributes(node)

  ###
  Description: Get all node links from current loaded node in graph. Remove the current node in graph. Re-add node
  with new properties. Re-add links
  TODO: Re-add node in same position
  ###
  updateNodeAttributes: (node) =>
    #Copy node
    #Add a new node with copied features
    currNode = @graph.getNode(node.id)
    currNodeLinks = currNode.links
    links = []
    for link in currNode.links
      links.push(fromId:link.fromId,toId:link.toId,strength:link.data)

    @graph.removeNode(node.id)
    @addNode(node)

    for l in links
      if l.fromId isnt node.id then @addLink(l.fromId,node.id,l.strength)
      else @addLink(node.id,l.toId,l.strength)

  toggleLinks:(from,to,adding) =>
    if adding
      @addNode(to)
      @addLink(from.id,to.id,2)
    else
      @removeLink(from.id,to)

  removeLink: (fromID,to) =>
    @graph.removeLink(@graph.hasLink(fromID,to.id))
    if @graph.getLinks(to.id).length < 1 then @graph.removeNode(to.id)
    else @updateNodeAttributes(to)

  addLink: (from,to,strength) =>
    if @graph.hasLink(from,to) is null then @graph.addLink(from,to,strength)

exports = this
exports.CommitteeGraph = new CommitteeGraph()