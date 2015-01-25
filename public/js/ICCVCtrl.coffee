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
    $scope.activeGroupName
    $scope.activeSchools = []
    $scope.activeDepartments = []
    $scope.showExtraInfo = false
    $scope.positionCount = []
    $scope.departmentCount = []
    $scope.committees = [
      {
        id: "C1"
        committee_name: "Committee One"
        people: ["cmckenzie"]
      }
      {
        id: "C3"
        committee_name: "CS Committee"
        people: [
          "aerkan"
          "dturnbull"
          "barr"
          "nprestopnik"
          "pdickson"
          "tdragon"
        ]
      }
      {
        id: "C4"
        committee_name: "Another Committee"
        people: [
          "jhilton"
          "euell"
          "ebleicher"
          "ppospisil"
        ]
      }
    ]

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

      #Convert/Correct any incorrect location information
      convert = () =>
      for username,workInfo of scope.workInfo
        for job in workInfo
          for nameIssue,nameFix of scope.canonical
            if nameIssue is job.location
              job.location = nameFix
      convert()


      #Map users who are only linked to a school for quick access
      user2SchoolMap = () =>
        schoolsMap = {}
        for username,work of scope.workInfo
          if work.length is 1
            for key,workInfo of work
              for school of scope.schools
                if school is workInfo.location
                  if schoolsMap[school] is undefined
                    schoolsMap[school] = []
                  schoolsMap[school].push(username)
        return schoolsMap

      #Make any modifications to school object before passing into graph here
      schools = () =>
        setLinkedUsers = (department) =>
          department.standardizedUsers = {}
          standardizedUsers = department.standardizedUsers
          for username,workInfo of scope.workInfo
            scope.workInfo[username].locations = {}
            for job in workInfo
              scope.workInfo[username].locations[job.location] = job.position
              if job.location is department.id
                standardizedUsers[username] = {
                  id: username,
                  type:"user",
                  size:"8"
                }



        for school,schoolInfo of scope.schools
          scope.schools[school].id = school
          scope.schools[school].type = "school"
          schoolInfo.standardizedDepartments = {}
          for department in schoolInfo.departments
            schoolInfo.standardizedDepartments[department] = {
              id: department,
              type:"department",
              size:"16"
              }
            setLinkedUsers(schoolInfo.standardizedDepartments[department])

        return

      schools()



      user2SchoolMap()
      options = container: attrs.container
      loadedData =
        workInfo         : scope.workInfo
        schools          : scope.schools
        schoolClicked    : scope.schoolClicked
        departmentClicked: scope.departmentClicked

      scope.g = new CommitteeGraph.initialize(element[0], loadedData, options)
      return


    #UI changes

    scope.activateAll = () ->
      for school, properties of scope.schools
        scope.schoolClicked(school)
        for d in properties.departments
          scope.departmentClicked(d)

    scope.toggleExtraInfo = TEI = (show) ->
      scope.showExtraInfo = show
      return

    scope.committeeClicked = (committee) ->
      scope.setActiveGroup committee.committee_name
      membersInfo = []
      $.each(committee.people, (key, name) ->
        membersInfo.push
          id: name
          workInfo: scope.workInfo[name]
      )

      scope.loadMembers membersInfo
      return

    scope.schoolClicked = (school) ->
      addDepartments        = school in scope.activeSchools
      scope.updateActiveSchools(school)
      selectedSchool = scope.schools[school]
      scope.updateGraph(selectedSchool,!addDepartments)


    scope.departmentClicked = (department) ->
      getLinkedSchool = () =>
        for school,schoolProperties of scope.schools
          for d in schoolProperties.departments
            if d is department
              return school

      addPeople = department in scope.activeDepartments
      if addPeople
        scope.activeDepartments.splice(scope.activeDepartments.indexOf(department),1)
      else
        scope.activeDepartments.push(department)

      linkedSchool = getLinkedSchool()
      selectedDepartment = scope.schools[linkedSchool].standardizedDepartments[department]
      scope.updateGraph(selectedDepartment,!addPeople)


      #Activate/deactivate all other schools a user may be connected to
        #TODO: This is a bad solution that I don't want to implement as it can cause an awful chain reaction



    scope.updateActiveSchools = (school) ->
      departments = []
      if school in scope.activeSchools
        scope.activeSchools.splice(scope.activeSchools.indexOf(school),1)
        for dep in scope.schools[school].departments
          #Deactivate department if it is currently active
          if scope.activeDepartments.indexOf(department) isnt -1
            scope.departmentClicked(department)
          departments.push(dep)
      else
        for dep in scope.schools[school].departments
          departments.push(dep)

      return departments


    scope.updateGraph =(nodes,add) ->
      scope.g.updateGraph(nodes,add)
      return

    scope.toggleDepartmentLabels = () ->
      $scope.activeDepartmentLabels = !$scope.activeDepartmentLabels


    scope.updateCounts = updateCounts = (membersInfo) ->
      scope.positionCount = []
      scope.departmentCount = []
      $.each membersInfo, (key, user) ->
        $.each user.workInfo, (key, workInfo) ->
          if scope.positionCount.length is 0
            scope.positionCount.push
              position: workInfo.position
              count: 1

          if scope.departmentCount.length is 0
            scope.departmentCount.push
              department: workInfo.location
              count: 1

          i = 0

          while i < scope.positionCount.length
            if scope.positionCount[i].position is workInfo.position
              scope.positionCount[i].count++
              break
            else if i is scope.positionCount.length - 1
              scope.positionCount.push
                position: workInfo.position
                count: 1

              break
            i++
          j = 0

          while j < scope.departmentCount.length
            if scope.departmentCount[j].department is workInfo.location
              scope.departmentCount[j].count++
              break
            else if j is scope.departmentCount.length - 1
              scope.departmentCount.push
                department: workInfo.location
                count: 1

              break
            j++
          return

        return

      return



  restrict: "E"
  replace: true
  templateUrl: "partials/graph.html"
  link: linker

angular.module("extra_information", []).directive "extraInformation", ->
  restrict: "E"
  templateUrl: "partials/extra_info.html"
  replace: true
