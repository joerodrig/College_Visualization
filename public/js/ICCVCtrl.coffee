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
    $scope.committees =
      "C1" : {
        id: "C1"
        committee_name: "Committee One"
        people: ["cmckenzie"]
      },
      "C3":{
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
      "C4":{
        id: "C4"
        committee_name: "Another Committee"
        people: [
          "jhilton"
          "euell"
          "ebleicher"
          "ppospisil"
        ]
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
                else if school is "Orphans"
                  workInfo.location = "Orphans Other"

                if inAdministration(workInfo.position)
                  workInfo.location = administration
                else if work.length is 1
                  workInfo.position = other

      user2SchoolMap()

      #Make any modifications to school object before passing into graph here
      schools = () =>
        usersToDepartment = (department) =>
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
                  fill:"#000"
                }

        for school,schoolInfo of scope.schools
          scope.schools[school].id = school
          scope.schools[school].type = "school"
          schoolInfo.standardizedDepartments = {}
          schoolInfo.standardizedUsers = {}
          for department in schoolInfo.departments
            schoolInfo.standardizedDepartments[department] = {
              id: department,
              type:"department"
              fill:"#88dddd"
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

      schools()


      options = container: attrs.container
      loadedData =
        workInfo         : scope.workInfo
        schools          : scope.schools
        schoolClicked    : scope.schoolClicked
        departmentClicked: scope.departmentClicked
        userClicked      : scope.userClicked

      scope.g = new CommitteeGraph.initialize(element[0], loadedData, options)
      return


    #UI changes

    scope.expandAllSchools = () ->
      for school, properties of scope.schools
        scope.schoolClicked(school)

    scope.toggleExtraInfo = TEI = (show) ->
      scope.showExtraInfo = show
      return

    scope.committeeClicked = (committee) ->
      #scope.setActiveGroup committee.committee_name

      for name in scope.committees[committee.id].people
        workLocations = scope.workInfo[name].locations
        for location,position of workLocations
          if location.indexOf("School") isnt -1
            if scope.isSchoolActive(location) is false
              scope.schoolClicked(location)
          else
            if scope.isDepartmentActive(location) is false
              scope.departmentClicked(location)

      return

    scope.schoolClicked = (school) ->
      addDepartments        = scope.isSchoolActive(school)
      scope.updateActiveSchools(school)
      selectedSchool = scope.schools[school]
      scope.updateGraph(selectedSchool,!addDepartments)


    scope.departmentClicked = (department) ->
      getLinkedSchool = () =>
        for school,schoolProperties of scope.schools
          for d in schoolProperties.departments
            if d is department
              return school

      linkedSchool = getLinkedSchool()

      addPeople = !scope.isDepartmentActive(department)
      if addPeople is true and scope.isSchoolActive(linkedSchool) is false
        scope.schoolClicked(linkedSchool)
      if addPeople is false
        scope.activeDepartments.splice(scope.activeDepartments.indexOf(department),1)
      else
        scope.activeDepartments.push(department)
        console.log(scope.activeDepartments)


      selectedDepartment = scope.schools[linkedSchool].standardizedDepartments[department]
      #Alter fill color of any users that are in schools or departments not already activated
      for username,properties of selectedDepartment.standardizedUsers
        for location,position of scope.workInfo[username].locations
          allActiveLocations = scope.isLocationActive(location)
          if allActiveLocations is false then break
        if allActiveLocations is false then properties.fill = "orange"
        else properties.fill = "#000"

      scope.updateGraph(selectedDepartment,addPeople)

    scope.userClicked = (user) ->
      #When a user is clicked, we want to find all of their locations and activate them
      #It doesn't make sense to collapse locations through user interaction -- we can only add
      schoolsArray = Object.keys(scope.schools)
      for location,position of scope.workInfo[user].locations
        if schoolsArray.indexOf(location) isnt -1
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

    scope.isSchoolActive = (school) ->
      return school in scope.activeSchools

    scope.isDepartmentActive = (department) ->
      return department in scope.activeDepartments

    scope.updateActiveSchools = (school) ->
      if school in scope.activeSchools
        scope.activeSchools.splice(scope.activeSchools.indexOf(school),1)
        for dep in scope.schools[school].departments
          if scope.isDepartmentActive(dep) is true then scope.departmentClicked(dep)
      else
        scope.activeSchools.push(school)

    scope.updateGraph =(nodes,add) ->
      scope.g.updateGraph(nodes,add)
      return

    scope.toggleDepartmentLabels = () ->
      $scope.activeDepartmentLabels = !$scope.activeDepartmentLabels


  restrict: "E"
  replace: true
  templateUrl: "partials/graph.html"
  link: linker

angular.module("extra_information", []).directive "extraInformation", ->
  restrict: "E"
  templateUrl: "partials/extra_info.html"
  replace: true
