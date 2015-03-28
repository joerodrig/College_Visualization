###
@ngdoc controller
@name ICCV.controller:ICCVCtrl

@Description ICCVApp loads and manages all

@Author Joseph Rodriguez
@Last Modified: March 27th, 2015
###
ICCVApp = angular.module("ICCV", [
  'ngAnimate',
  'iccv.graph',
  'iccv.committeeBar',
  'iccv.interactiveBar']);


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

    $q.all([canonical,workInfo,schools,committees]).then(() ->
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
              textSize:"26px"
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

      console.log("Dependencies loaded")
      fixWorkInfo()
      mapUsersToSchool()
      processSchools()

      return {
        workInfo  : workInfo
        schools   : schools
        committees: committees
      }
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

