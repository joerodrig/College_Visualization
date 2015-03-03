###*
@ngdoc controller
@name ICCV.controller:ICCVCtrl

@description ICCVApp loads and manages all graph dependencies. When all dependencies are loaded, a graph instance is created
  on the screen.

@Author Joseph Rodriguez
###
ICCVApp = angular.module("ICCV", ['ngAnimate'])


###
The useInfoService asynchronously loads and formats all of the initial workInfo and school data
@requires $http,$q
###
ICCVApp.service('userInfoService', ($http,$q) ->

  ###
  Loads and formats all dependencies to be used
  Returns [Object]
  ###
  getWorkInfo = () ->
    #Gather all dependencies
    workInfo  = loadWorkInfo().then((workData) ->
                  workInfo = workData
                )
    canonical = loadCanonical().then((canonicalData) ->
                  canonical = canonicalData
                )
    schools   = loadSchools().then((schoolData) ->
                  schools = schoolData
    )
    committees = loadCommittees().then((committeeData) ->
                  committees = committeeData
    )

    $q.all([canonical,workInfo,schools,committees]).then( () ->
      console.log("Dependencies loaded")
      fixWorkInfo()
      mapUsersToSchool()
      processSchools()

      return {
        workInfo  : workInfo
        schools   : schools
        committees: committees
      }


    #Convert/Correct any incorrect location information
    fixWorkInfo = () ->
      for username,workInf of workInfo
        for job in workInf
          for jobNameIssue,jobNameFix of canonical
            if jobNameIssue is job.location then job.location = jobNameFix

    #Map users who are only linked to a school for quick access
    mapUsersToSchool = () ->
      inAdministration = (position) ->
        return position.indexOf("Dean") isnt -1 or position.indexOf("Provost") isnt -1 or position.indexOf("President") isnt -1
      for username,work of workInfo
        for key,workInf of work
          for school,schoolInfo of schools
            if school is workInf.location
              if inAdministration(workInf.position) then workInf.location = school + "Administration"
              else if work.length is 1 then workInf.position = school + "Other"

    processSchools = () ->
      usersToDepartment = (department) ->
        department.standardizedUsers = {}
        standardizedUsers = department.standardizedUsers
        for username,workInf of workInfo
          workInfo[username].locations = {}
          for job in workInf
            workInfo[username].locations[job.location] = job.position
            if job.location is department.id
              standardizedUsers[username] = {
                id      : username
                type    :"user"
                size    :"20"
                textSize:"16px"
                fill    :"#4568A3"
              }

      for school,schoolInfo of schools
        schools[school].id   = school
        schools[school].type = "school"
        schools[school].fill = "#076DA4"
        schoolInfo.standardizedDepartments = {}
        schoolInfo.standardizedUsers       = {}
        for department in schoolInfo.departments
          schoolInfo.standardizedDepartments[department] = {
            id      : department
            type    :"department"
            fill    :"#6A93A9"
            textSize:"20px"
          }
          usersToDepartment(schoolInfo.standardizedDepartments[department])
          schoolInfo.standardizedDepartments[department].size = Object.keys(schoolInfo.standardizedDepartments[department].standardizedUsers).length
          if schoolInfo.standardizedDepartments[department].size < 12
            schoolInfo.standardizedDepartments[department].size = 12
        for username,work of workInfo
          if work.length is 1
            for key,workInf of work
              if school is workInf.location
                schoolInfo.standardizedUsers[username] = {
                  id  : username,
                  type:"user",
                  size:"8"
                  fill:"#000"
                }
      return
    )



  ###
  Load and cache work info
  ###
  loadWorkInfo = () ->
    defer = $q.defer()
    $http.get("json/work_info.json", {cache: 'true'}).success((data, status, headers, config) ->
      defer.resolve(data)
    )
    return defer.promise

  ###
  Load and cache committee relationships
  ###
  loadCommittees = () ->
    defer = $q.defer()
    $http.get("json/committees.json", {cache: 'true'}).success((data, status, headers, config) ->
      defer.resolve(data)
    )
    return defer.promise

  ###
  Load and cache schools
  ###
  loadSchools = () ->
    defer = $q.defer()
    $http.get("json/schools_departments.json", {cache: 'true'}).success((data, status, headers, config) ->
      defer.resolve(data)
    )
    return defer.promise

  ###
  Load and cache canonical data
  ###
  loadCanonical = () ->
    defer = $q.defer()
    $http.get("json/canonical.json", {cache: 'true'}).success((data, status, headers, config) ->
      defer.resolve(data)
    )
    return defer.promise

  return {
    getWorkInfo : getWorkInfo
    getSchools  : loadSchools

  }
)


###*
Committee Graph directive
###
ICCVApp.directive("graph",['userInfoService', ($http, $q,userInfoService) ->
  linker = (scope, element, attrs) ->

    console.log "( ͡° ͜ʖ ͡  "
    scope.expandAllSchools   = false
    scope.pinAllSchools      = false
    scope.showSettings       = true
    scope.activeCommittee    = {id: null, members: [],departments: []}


    #Once all dependencies load, instantiate graph
    scope.$watch('workInfo',(newval,oldval) ->
      loadGraph = () ->
        options = container: attrs.container
        loadedData =
          workInfo         : scope.workInfo
          schools          : scope.schools

        scope.g = new CommitteeGraph.initialize(element[0], loadedData, options)

        if (attrs.graphtype is "explorative")
          scope.graphType = "explorative"
          scope.committeeBarExists = false

        else if (attrs.graphtype is "committee")
          scope.graphType          = "committee"
          scope.committeeBarExists = true


        #Handle Click events within element
        $(element).on('mousedown',(e) ->
          oldX   = e.pageX
          oldY   = e.pageY
          nodeClicked = e.target.attributes.identifier
          if nodeClicked isnt undefined
            element.one('mouseup',(e) ->
              newX   = e.pageX
              newY   = e.pageY
              if (Math.abs(oldX - newX) < 15 and Math.abs(oldY - newY) < 15)
                scope.nodeClicked(e)
            )
        )

      #Loading graph once dependencies load
      if (newval isnt undefined)
        loadGraph()
    )


    #UI changes


    scope.toggleCommitteeBar = (exists) ->
      scope.committeeBarExists = exists


    scope.changeGraphView = () ->
      toCommitteeGraph = () ->
        attrs.graphtype = "committee"
        scope.graphType = "committee"
        scope.toggleCommitteeBar(true)
        scope.toggleSchools(false)
      toExplorativeGraph = () ->
        scope.toggleCommitteeBar(false)
        scope.graphType = "explorative"
        attrs.graphtype = "explorative"
        scope.activeCommittee    = {id: null, members: [],departments: []}
        #NOTE Toggleschools has to go after active committee being nullified in this case
        scope.toggleSchools(false)

        for department in scope.activeCommittee.departments
          scope.departmentClicked(department)

      if attrs.graphtype is "explorative" then toCommitteeGraph()
      else if attrs.graphtype is "committee" then toExplorativeGraph()


    scope.nodeClicked = (e) ->
      nodeType = e.target.className.baseVal
      node = e.target.attributes.identifier
      if node isnt undefined
        nodeId = node.value
        if nodeType is "department_node" or nodeType is "department_node_label" then scope.departmentClicked(nodeId)
        else if nodeType is "school_node" or nodeType is "school_node_label" then scope.schoolClicked(nodeId)
        else if nodeType is "user_node" or nodeType is "user_node_label" then scope.userClicked(nodeId)

    scope.toggleSchools = (expand) ->
        for school, properties of scope.schools
          if expand is true and scope.isSchoolActive(school) isnt true then scope.schoolClicked(school)
          else if expand isnt true and scope.isSchoolActive(school) is true
            scope.schoolClicked(school)
            #TODO: This ensures departments of an active committee don't stay closed. Should implement a way
            #to make sure they never close in the first place
            if scope.activeCommittee.id isnt null
              for department in scope.activeCommittee.departments
                if scope.isDepartmentActive(department) isnt true
                  scope.departmentClicked(department)


    scope.pinSchools = (pin) ->
      for school,properties of scope.schools
        scope.g.pinNode(school)


    scope.toggleSettings = (show) ->
      scope.showSettings = show
      return


    scope.committeeClicked = (committee) ->
      #Remove links to previous active committee members
      if scope.activeCommittee.id isnt null
        scope.updateGraph({type:"committee_links",members:scope.activeCommittee.members},false)

      scope.activeCommittee.members     = []
      scope.activeCommittee.departments = []
      scope.activeCommittee.id          = committee.committee_name

      #Save members and departments to list to keep track of representation
      for name in scope.committees[committee.id].people
        scope.activeCommittee.members.push(name)
        workLocations = scope.workInfo[name].locations
        for location,position of workLocations
          if location.indexOf("School") is -1 and scope.isFoundIn(location,scope.activeCommittee.departments) isnt true
            scope.activeCommittee.departments.push(location)

      #Deactivate all departments to refresh user nodes
      for school,properties of scope.schools
        for department,info of properties.standardizedDepartments
          if scope.isDepartmentActive(department) is true then scope.departmentClicked(department)

      #Activate any schools or departments they are in that aren't active for committee
      for name in scope.committees[committee.id].people
        workLocations = scope.workInfo[name].locations
        for location,position of workLocations
          if location.indexOf("School") is -1
            if scope.isDepartmentActive(location) is false
              scope.departmentClicked(location)

      scope.updateGraph({type:"committee_links",members:scope.activeCommittee.members},true)
      return

    scope.isFoundIn = (term, array) -> array.indexOf(term) isnt -1

    scope.schoolClicked = (school) ->
      addDepartments        = scope.isSchoolActive(school)
      scope.updateActiveSchools(school)
      selectedSchool = scope.schools[school]
      scope.updateGraph(selectedSchool,!addDepartments)

    scope.departmentClicked = (department) ->
      getLinkedSchool = () =>
        for school,schoolProperties of scope.schools
          for d in schoolProperties.departments
            if d is department then return school

      linkedSchool = getLinkedSchool()

      addPeople = !scope.isDepartmentActive(department)
      if addPeople is true and scope.isSchoolActive(linkedSchool) is false then scope.schoolClicked(linkedSchool)
      if addPeople is false then scope.activeDepartments.splice(scope.activeDepartments.indexOf(department),1)
      else scope.activeDepartments.push(department)

      selectedDepartment = scope.schools[linkedSchool].standardizedDepartments[department]

      #NOTE: Depending on graph type, user nodes will take on different colors
      if scope.graphType is "explorative"
        for username,properties of selectedDepartment.standardizedUsers
          locs = Object.keys(scope.workInfo[username].locations)
          if locs.length > 2 then properties.fill = "orange"
          else if locs.length is 2
            if locs[0].indexOf("School") isnt -1 and locs[1].indexOf("School") isnt -1 then properties.fill = "yellow"
            else properties.fill = "#4568A3"
          else properties.fill = "#4568A3"

      else if scope.graphType is "committee"
        for username,properties of selectedDepartment.standardizedUsers
          for location,position of scope.workInfo[username].locations
            if scope.isFoundIn(username,scope.activeCommittee.members) then properties.fill = "orange"
            else if scope.isFoundIn(location,scope.activeCommittee.departments) then properties.fill = "#124654"

      scope.updateGraph(selectedDepartment,addPeople)

    scope.userClicked = (user) ->
      locationIsSchool = () ->
        return schoolsArray.indexOf(location) isnt -1
      #When a user is clicked, we want to find all of their locations and activate them
      #It doesn't make sense to collapse locations through user interaction -- we can only add
      schoolsArray = Object.keys(scope.schools)
      for location,position of scope.workInfo[user].locations
        if locationIsSchool()
          if scope.isSchoolActive(location) isnt true
            scope.schoolClicked(location)
        else if scope.isDepartmentActive(location) isnt true
          scope.departmentClicked(location)

    ###
    Description: We do not know or need to know whether the location is a department or school,
     only whether or not the current location is active
    Input: [String] location - location name
    ###
    scope.isLocationActive = (location) ->
      return scope.isSchoolActive(location) or scope.isDepartmentActive(location)

    ###
    Description: Checking to see if school is active
    Input: [String] school : name of the school
    ###
    scope.isSchoolActive = (school) ->
      return school in scope.activeSchools
    ###
    Description: Checking to see if department is active
    Input: [String] school : name of the department
    ###
    scope.isDepartmentActive = (department) ->
      return department in scope.activeDepartments

    scope.updateActiveSchools = (school) ->
      if school in scope.activeSchools
        scope.activeSchools.splice(scope.activeSchools.indexOf(school),1)
        for dep in scope.schools[school].departments
          if scope.isDepartmentActive(dep) is true then scope.departmentClicked(dep)
      else
        scope.activeSchools.push(school)

    scope.updateGraph = (nodes,add) ->
      scope.g.updateGraph(nodes,add)

    scope.toggleDepartmentLabels = () ->
      $scope.activeDepartmentLabels = !$scope.activeDepartmentLabels

  return {
  restrict    : "E"
  replace     : true
  controller  : 'graphCtrl'
  controllerAs: 'graphCtrl'
  templateUrl : "partials/graph.html"
  link        : linker
  }
])
.controller('graphCtrl',($scope,userInfoService) ->
  gCtrl = @
  gCtrl.userInfoService = userInfoService
  $scope.activeDepartmentLabels = true
  $scope.activeSchools      = []
  $scope.activeDepartments  = []
  $scope.positionCount      = []
  $scope.departmentCount    = []

  #Loading in workInfo from service
  gCtrl.userInfoService.getWorkInfo().then((data) ->
    $scope.workInfo   = data.workInfo
    $scope.schools    = data.schools
    $scope.committees = data.committees
  )
)


ICCVApp.directive "extraInformation", ->
  linker = (scope, element, attrs) ->
    scope.pinSchools = "Schools Pinned"

  restrict: "E"
  require:"^graph"
  templateUrl: "partials/extra_info.html"
  replace: true


ICCVApp.directive('visualizationNavbar', () ->
    linker = (scope,element,attrs) ->
      scope.inNavBar      = false



    return {
    require: "^graph"
    templateUrl : "partials/navigation_bar.html"
    replace     : true
    restrict    : "E"
    controller  : 'navbarCtrl'
    controllerAs: 'navbarCtrl'
    link: linker
    }
)
.controller('navbarCtrl', () ->
  return
)