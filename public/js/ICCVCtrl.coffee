###*
@ngdoc controller
@name ICCV.controller:ICCVCtrl

@description


@requires $scope
###
ICCVApp = angular.module("ICCV", ["extra_information"])
ICCVApp.controller "ICCVCtrl", [
  "$scope"
  "$http"
  ($scope, $http) ->
    $scope.activeDepartmentLabels = true
    $scope.committeesMenu
    $scope.activeGraph        = "explorative"
    $scope.activeCommittee    = {id: null, members: []}
    $scope.activeSchools      = []
    $scope.activeDepartments  = []
    $scope.positionCount      = []
    $scope.departmentCount    = []
    $scope.committees =
      "C5":{
        id:"C5"
        committee_name:"H&S Senate"
        people: ["bmurday","jjolly","jtennant","cstetson","kdsullivan","pcole","wdann","mdifrancesco",
                 "gleitman","mklemm","sstansfield","rplante","dturkon","eganh"]
      }
      "C6":{
        id:"C6"
        committee_name:"Faculty Council"
        people: ["dduke","mgeiszler","jharrington","pwinters","brappa",
                 "pconstantinou","mcozzoli","hdichter","dlong","cmcnamara",
                 "tswensen","jwinslow","pcole","scondeescu","vconger",
                 "jfreitag","tgalanthay","chenderson","tpatrone","jpfrehm",
                 "rosentha","seltzer","atheobald","dtindall","rwagner",
                 "cbarboza","dbirr","cdimaras","drifkin","rothbart"]
      }
      "C7":{
        id:"C7"
        committee_name:"Instructional Dev. Fund"
        people: ["malpass","jbrenner","thoppenrath","kkomaromi","dmontgom",
                 "monroej","jpowers","wasick"]
      }

    # [asynchronously] Retrieving work info
    $scope.workInfo = $http.get("json/work_info.json").success((data, status, headers, config) ->
      $scope.workInfo = data
      return
    )

    # [asynchronously] Retrieving school & department info
    $scope.schools = $http.get("json/schools_departments.json").success((data, status, headers, config) ->
      $scope.schools = data
      return
    )

    $scope.canonical = $http.get("json/canonical.json").success((data, status, headers, config) ->
      $scope.canonical = data
      return
    )

    $scope.changeView = () ->
      if $scope.activeGraph is "explorative"
        $scope.activeGraph = "committee"
      else if $scope.activeGraph is "committee"
        $scope.activeGraph = "explorative"

]

###*
Committee Graph directive
###
ICCVApp.directive "graph", ($http, $q) ->
  linker = (scope, element, attrs) ->
    #Initialize graph(s) once required information has successfully loaded
    $q.all([
      scope.workInfo
      scope.schools
      scope.canonical
    ]).then ->
      console.log "Graph Dependencies Loaded"
      console.log "( ͡° ͜ʖ ͡° I see you  "
      scope.expandAllSchools   = false
      scope.pinAllSchools      = false
      scope.showSettings       = true



      #Convert/Correct any incorrect location information
      convert = do =>
      for username,workInfo of scope.workInfo
        for job in workInfo
          for nameIssue,nameFix of scope.canonical
            if nameIssue is job.location then job.location = nameFix


      #Map users who are only linked to a school for quick access
      user2SchoolMap = do =>
        inAdministration = (position) =>
          return workInfo.position.indexOf("Dean") isnt -1 or workInfo.position.indexOf("Provost") isnt -1 or workInfo.position.indexOf("President") isnt -1
        for username,work of scope.workInfo
          for key,workInfo of work
            for school,schoolInfo of scope.schools
              if school is workInfo.location
                if school is "School of Humanities and Sciences"
                  administration = "Humanities and Sciences Administration"
                  other          = "Humanities and Sciences Other"
                else if school is "School of Music"
                  administration = "Music Administration"
                  other          = "Music Other"
                else if school is "School of Health Sciences and Human Performance"
                  administration = "Health Sciences Administration"
                  other          = "Health Sciences Other"
                else if school is "Roy H. Park School of Communications"
                  administration = "Park Administration"
                  other          = "Park Other"
                else if school is "School of Business"
                  administration = "Business Administration"
                  other          = "Business Other"
                else if school is "Orphans" then workInfo.location = "Orphans Other"

                if inAdministration(workInfo.position) then workInfo.location = administration
                else if work.length is 1 then workInfo.position = other


      #Make any modifications to school object before passing into graph here
      schools = do =>
        usersToDepartment = (department) =>
          department.standardizedUsers = {}
          standardizedUsers = department.standardizedUsers
          for username,workInfo of scope.workInfo
            scope.workInfo[username].locations = {}
            for job in workInfo
              scope.workInfo[username].locations[job.location] = job.position
              if job.location is department.id
                standardizedUsers[username] = {
                  id: username
                  type:"user"
                  size:"20"
                  textSize:"16px"
                  fill:"#4568A3"
                }

        for school,schoolInfo of scope.schools
          scope.schools[school].id = school
          scope.schools[school].type = "school"
          scope.schools[school].fill = "#076DA4"
          schoolInfo.standardizedDepartments = {}
          schoolInfo.standardizedUsers = {}
          for department in schoolInfo.departments
            schoolInfo.standardizedDepartments[department] = {
              id: department
              type:"department"
              fill:"#6A93A9"
              textSize:"20px"
              }
            usersToDepartment(schoolInfo.standardizedDepartments[department])
            schoolInfo.standardizedDepartments[department].size = Object.keys(schoolInfo.standardizedDepartments[department].standardizedUsers).length
            if schoolInfo.standardizedDepartments[department].size < 12
              schoolInfo.standardizedDepartments[department].size = 12
          for username,work of scope.workInfo
            if work.length is 1
              for key,workInfo of work
                  if school is workInfo.location
                    schoolInfo.standardizedUsers[username] = {
                      id: username,
                      type:"user",
                      size:"8"
                      fill:"#000"
                    }
        return

      options = container: attrs.container
      loadedData =
        workInfo         : scope.workInfo
        schools          : scope.schools

      scope.g = new CommitteeGraph.initialize(element[0], loadedData, options)

      if (attrs.graphtype is "explorative")
        scope.graphType = "explorative"
        scope.committeeBarExists = false
        #Handle Click events within element
        element.bind("click",(e)->
          nodeClicked = e.toElement.attributes.identifier
          if nodeClicked isnt undefined then scope.nodeClicked(e)
        )

      else if (attrs.graphtype is "committee")
        scope.graphType = "committee"
        scope.committeeBarExists = true

      return


    #UI changes
    scope.changeGraphView = () ->
      console.log("Switching view ")
      scope.changeView()
      return


    scope.nodeClicked = (e) ->
      if e.shiftKey is true
        nodeType = e.target.className.baseVal
        nodeId = e.target.attributes.identifier.value
        if nodeType is "department_node" or nodeType is "department_node_label" then scope.departmentClicked(nodeId)
        else if nodeType is "school_node" or nodeType is "school_node_label" then scope.schoolClicked(nodeId)
        else if nodeType is "user_node" or nodeType is "user_node_label" then scope.userClicked(nodeId)

    scope.toggleSchools = (expand) ->
        for school, properties of scope.schools
          if expand is true and scope.isSchoolActive(school) isnt true then scope.schoolClicked(school)
          else if expand isnt true and scope.isSchoolActive(school) is true then scope.schoolClicked(school)


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
      #TODO: Need to be smarter about this..Performance hit
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
            if locs[0].indexOf("School") isnt -1 and locs[1].indexOf("School") isnt -1 then properties.fill = "orange"
            else properties.fill = "#4568A3"
          else properties.fill = "#4568A3"
      else if scope.graphType is "committee"
        for username,properties of selectedDepartment.standardizedUsers
          for location,position of scope.workInfo[username].locations
            if scope.isFoundIn(username,scope.activeCommittee.members) then properties.fill = "orange"
            else if scope.isFoundIn(location,scope.activeCommittee.departments) then properties.fill = "#124654"

      scope.updateGraph(selectedDepartment,addPeople)

    scope.userClicked = (user) ->
      #When a user is clicked, we want to find all of their locations and activate them
      #It doesn't make sense to collapse locations through user interaction -- we can only add
      schoolsArray = Object.keys(scope.schools)
      for location,position of scope.workInfo[user].locations
        if schoolsArray.indexOf(location) isnt -1
          if scope.isSchoolActive(location) isnt true then scope.schoolClicked(location)
        else if scope.isDepartmentActive(location) isnt true then scope.departmentClicked(location)

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
      return

    scope.toggleDepartmentLabels = () ->
      $scope.activeDepartmentLabels = !$scope.activeDepartmentLabels

  restrict: "E"
  replace: true
  templateUrl: "partials/graph.html"
  link: linker


angular.module("extra_information", []).directive "extraInformation", ->
  linker = (scope, element, attrs) ->
    scope.pinSchools = "Schools Pinned"

  restrict: "E"
  templateUrl: "partials/extra_info.html"
  replace: true
