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



  initial: () =>
    #nodePosition = @graphParameters.renderer.layout.getNodePosition
    mainNode = {id:"IC",type:"main"}
    @graphParameters.renderer.layout.pinNode(@addNode(mainNode),true)
    for school,properties of @schoolInfo.schools
      schoolNode = {id:school,type:properties.type,size:properties.departments.length}
      @addNode(schoolNode)
      @graph.addLink(schoolNode.id,mainNode.id,schoolNode.size)



  updateGraph: (primaryNode,adding) =>

    if primaryNode.type is "school"
      for departmentName,properties of primaryNode.standardizedDepartments
        if adding
          @toggleLinks(primaryNode,properties,adding)

    if primaryNode.type is "department"
       for username,properties of primaryNode.standardizedUsers
        if adding
         @toggleLinks(primaryNode,properties,adding)




      #@toggleLinks(node,adding)
    #for node in nodes
    #  if adding
    #    @addNode(node)

    ###
    if node.type is "user"
      for work in node.workInfo
        hasNode = @graph.getNode(work.location)
        #Checking to see if department or school
        if hasNode is undefined
          associatedSchool = @returnSchool(work.location)
          if @graph.hasLink(work.location,associatedSchool) is null
            @addLink(@addNode(work.location,"dn"), @linkSchool(work.location),1)
        else if hasNode
          if work.location.indexOf("School") isnt -1
            #Add a link to the school if user position is dean, or if that is the only link
            if node.workInfo.length == 1 || work.location.indexOf("Dean") isnt -1
              @addLink(node.id,work.location,2)
          else
            @addLink(node.id,work.location)
    ###




  addLink: (from,to,strength) =>
    @graph.addLink(from,to,strength)


  rmvLink: (link) =>
    console.log(@graph.removeLink(link))


  addNode: (node)=>
    if @graph.getNode(node.id) is undefined
      if node.type is "user"
        @graph.addNode(node.id,
          fill: "#000"
          size: "12"
          type:"user_node"
        )
      else if node.type is "department"
        @graph.addNode(node.id,
          fill: "#AAA"
          size: node.size
          type: "department_node"
        )

      else if node.type is "school"
        if node.size < 10
          node.size = 10
        else if node.size > 25
          node.size  = 25

        @graph.addNode(node.id,
          fill: "#a3ff00"
          size: node.size*2
          type:"school_node")

      else if node.type is "main"
        @graph.addNode(node.id,
        fill: "blue"
        size:"22"
        type:"main_node"
        )


  rmvNode:(node)=>
    #if node.type is "department"
      #Go through each person connected to department
        #If person is connected to another department
          #If that department is not connected to anything else, delete it
        #Else remove person

        #Remove each department



  toggleLinks:(from,to,adding) =>
    if adding
      @addNode(to)
      @addLink(from.id,to.id,2)
    ###
    else
      @graph.removeLink(@graph.hasLink(node.id,department.id))
      @graph.removeNode(department.id)
    ###


    if not adding then @rmvNode(node)



exports = this
exports.CommitteeGraph = new CommitteeGraph()