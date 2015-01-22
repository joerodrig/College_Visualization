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
    ]).then ->
      console.log "Graph Dependencies Loaded"
      options = container: attrs.container
      loadedData =
        workInfo         : scope.workInfo
        schoolLinker     : scope.schools
        schoolClicked    : scope.schoolClicked
        departmentClicked: scope.departmentClicked

      scope.g = new CommitteeGraph.initialize(element[0], loadedData, options)
      return


    #UI changes
    scope.toggleExtraInfo = TEI = (show) ->
      scope.showExtraInfo = show
      return

    scope.committeeClicked = (committee) ->
      scope.setActiveGroup committee.committee_name
      membersInfo = []
      $.each(committee.people, (key, name) ->
        membersInfo.push
          name: name
          workInfo: scope.workInfo[name]
      )

      scope.loadMembers membersInfo
      scope.updateCounts membersInfo
      return

    scope.schoolClicked = (school) ->
      console.log "School clicked"
      deps = []
      $.each(scope.schools[school].departments, (index, department) ->
        deps.push(id: department, type:"department",school:school)
      )
      if school in scope.activeSchools
        scope.activeSchools.splice(scope.activeSchools.indexOf(school),1)
        addDepartments = false
      else
        scope.activeSchools.push(school)
        addDepartments = true


      scope.updateGraph(deps,addDepartments)

    #scope.updateCounts(membersInfo);


    scope.departmentClicked = (department) ->
      console.log "Department Clicked"
      people = []
      $.each(scope.workInfo, (person, info) ->
        workInfo = info
        for key,work of info
          if work.location is department
            people.push(id: person, type:"user",workInfo: workInfo)
            return
      )

      addPeople = department in scope.activeDepartments
      if addPeople
        scope.activeDepartments.splice(scope.activeDepartments.indexOf(department),1)
      else
       scope.activeDepartments.push(department)

      scope.updateGraph(people,!addPeople)

    scope.updateGraph =(nodes,add) ->
      scope.g.updateGraph(nodes,add)
      return

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

    scope.setActiveGroup = (name) ->
      scope.activeGroupName = name
      return

    return
  $("g").click ->
    console.log "School node clicked!"
    return

  restrict: "E"
  replace: true
  templateUrl: "partials/graph.html"
  link: linker

angular.module("extra_information", []).directive "extraInformation", ->
  restrict: "E"
  templateUrl: "partials/extra_info.html"
  replace: true
