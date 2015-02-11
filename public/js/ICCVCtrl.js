// Generated by CoffeeScript 1.8.0

/**
@ngdoc controller
@name ICCV.controller:ICCVCtrl

@description


@requires $scope
 */

(function() {
  var ICCVApp,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  ICCVApp = angular.module("ICCV", ["extra_information"]);

  ICCVApp.controller("ICCVCtrl", [
    "$scope", "$http", function($scope, $http) {
      $scope.activeDepartmentLabels = true;
      $scope.activeSchools = [];
      $scope.activeDepartments = [];
      $scope.positionCount = [];
      $scope.departmentCount = [];
      $scope.committees = {
        "C5": {
          id: "C5",
          committee_name: "H&S Senate",
          people: ["bmurday", "jjolly", "jtennant", "cstetson", "kdsullivan", "pcole", "wdann", "mdifrancesco", "gleitman", "mklemm", "sstansfield", "rplante", "dturkon", "eganh"]
        },
        "C6": {
          id: "C6",
          committee_name: "Faculty Council",
          people: ["dduke", "mgeiszler", "jharrington", "pwinters", "brappa", "pconstantinou", "mcozzoli", "hdichter", "dlong", "cmcnamara", "tswensen", "jwinslow", "pcole", "scondeescu", "vconger", "jfreitag", "tgalanthay", "chenderson", "tpatrone", "jpfrehm", "rosentha", "seltzer", "atheobald", "dtindall", "rwagner", "cbarboza", "dbirr", "cdimaras", "drifkin", "rothbart"]
        },
        "C7": {
          id: "C7",
          committee_name: "Instructional Dev. Fund",
          people: ["malpass", "jbrenner", "thoppenrath", "kkomaromi", "dmontgom", "monroej", "jpowers", "wasick"]
        }
      };
      $scope.workInfo = $http.get("json/work_info.json").success(function(data, status, headers, config) {
        $scope.workInfo = data;
      });
      $scope.schools = $http.get("json/schools_departments.json").success(function(data, status, headers, config) {
        $scope.schools = data;
      });
      return $scope.canonical = $http.get("json/canonical.json").success(function(data, status, headers, config) {
        $scope.canonical = data;
      });
    }
  ]);


  /**
  Committee Graph directive
   */

  ICCVApp.directive("graph", function($http, $q) {
    var linker;
    linker = function(scope, element, attrs) {
      $q.all([scope.workInfo, scope.schools, scope.canonical]).then(function() {
        var convert, job, loadedData, nameFix, nameIssue, options, schools, user2SchoolMap, username, workInfo, _i, _len, _ref, _ref1;
        console.log("Graph Dependencies Loaded");
        console.log("( ͡° ͜ʖ ͡° I see you  ");
        scope.expandAllSchools = false;
        scope.pinAllSchools = false;
        scope.showSettings = true;
        scope.activeCommittee = {
          id: null,
          members: [],
          departments: []
        };
        convert = (function(_this) {
          return function() {};
        })(this)();
        _ref = scope.workInfo;
        for (username in _ref) {
          workInfo = _ref[username];
          for (_i = 0, _len = workInfo.length; _i < _len; _i++) {
            job = workInfo[_i];
            _ref1 = scope.canonical;
            for (nameIssue in _ref1) {
              nameFix = _ref1[nameIssue];
              if (nameIssue === job.location) {
                job.location = nameFix;
              }
            }
          }
        }
        user2SchoolMap = (function(_this) {
          return function() {
            var administration, inAdministration, key, other, school, schoolInfo, work, _ref2, _results;
            inAdministration = function(position) {
              return workInfo.position.indexOf("Dean") !== -1 || workInfo.position.indexOf("Provost") !== -1 || workInfo.position.indexOf("President") !== -1;
            };
            _ref2 = scope.workInfo;
            _results = [];
            for (username in _ref2) {
              work = _ref2[username];
              _results.push((function() {
                var _results1;
                _results1 = [];
                for (key in work) {
                  workInfo = work[key];
                  _results1.push((function() {
                    var _ref3, _results2;
                    _ref3 = scope.schools;
                    _results2 = [];
                    for (school in _ref3) {
                      schoolInfo = _ref3[school];
                      if (school === workInfo.location) {
                        if (school === "School of Humanities and Sciences") {
                          administration = "Humanities and Sciences Administration";
                          other = "Humanities and Sciences Other";
                        } else if (school === "School of Music") {
                          administration = "Music Administration";
                          other = "Music Other";
                        } else if (school === "School of Health Sciences and Human Performance") {
                          administration = "Health Sciences Administration";
                          other = "Health Sciences Other";
                        } else if (school === "Roy H. Park School of Communications") {
                          administration = "Park Administration";
                          other = "Park Other";
                        } else if (school === "School of Business") {
                          administration = "Business Administration";
                          other = "Business Other";
                        } else if (school === "Orphans") {
                          workInfo.location = "Orphans Other";
                        }
                        if (inAdministration(workInfo.position)) {
                          _results2.push(workInfo.location = administration);
                        } else if (work.length === 1) {
                          _results2.push(workInfo.position = other);
                        } else {
                          _results2.push(void 0);
                        }
                      } else {
                        _results2.push(void 0);
                      }
                    }
                    return _results2;
                  })());
                }
                return _results1;
              })());
            }
            return _results;
          };
        })(this)();
        schools = (function(_this) {
          return function() {
            var department, key, school, schoolInfo, usersToDepartment, work, _j, _len1, _ref2, _ref3, _ref4;
            usersToDepartment = function(department) {
              var standardizedUsers, _ref2, _results;
              department.standardizedUsers = {};
              standardizedUsers = department.standardizedUsers;
              _ref2 = scope.workInfo;
              _results = [];
              for (username in _ref2) {
                workInfo = _ref2[username];
                scope.workInfo[username].locations = {};
                _results.push((function() {
                  var _j, _len1, _results1;
                  _results1 = [];
                  for (_j = 0, _len1 = workInfo.length; _j < _len1; _j++) {
                    job = workInfo[_j];
                    scope.workInfo[username].locations[job.location] = job.position;
                    if (job.location === department.id) {
                      _results1.push(standardizedUsers[username] = {
                        id: username,
                        type: "user",
                        size: "20",
                        textSize: "16px",
                        fill: "#4568A3"
                      });
                    } else {
                      _results1.push(void 0);
                    }
                  }
                  return _results1;
                })());
              }
              return _results;
            };
            _ref2 = scope.schools;
            for (school in _ref2) {
              schoolInfo = _ref2[school];
              scope.schools[school].id = school;
              scope.schools[school].type = "school";
              scope.schools[school].fill = "#076DA4";
              schoolInfo.standardizedDepartments = {};
              schoolInfo.standardizedUsers = {};
              _ref3 = schoolInfo.departments;
              for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
                department = _ref3[_j];
                schoolInfo.standardizedDepartments[department] = {
                  id: department,
                  type: "department",
                  fill: "#6A93A9",
                  textSize: "20px"
                };
                usersToDepartment(schoolInfo.standardizedDepartments[department]);
                schoolInfo.standardizedDepartments[department].size = Object.keys(schoolInfo.standardizedDepartments[department].standardizedUsers).length;
                if (schoolInfo.standardizedDepartments[department].size < 12) {
                  schoolInfo.standardizedDepartments[department].size = 12;
                }
              }
              _ref4 = scope.workInfo;
              for (username in _ref4) {
                work = _ref4[username];
                if (work.length === 1) {
                  for (key in work) {
                    workInfo = work[key];
                    if (school === workInfo.location) {
                      schoolInfo.standardizedUsers[username] = {
                        id: username,
                        type: "user",
                        size: "8",
                        fill: "#000"
                      };
                    }
                  }
                }
              }
            }
          };
        })(this)();
        options = {
          container: attrs.container
        };
        loadedData = {
          workInfo: scope.workInfo,
          schools: scope.schools
        };
        scope.g = new CommitteeGraph.initialize(element[0], loadedData, options);
        if (attrs.graphtype === "explorative") {
          scope.graphType = "explorative";
          scope.committeeBarExists = false;
          element.bind("click", function(e) {
            var nodeClicked;
            nodeClicked = e.toElement.attributes.identifier;
            if (nodeClicked !== void 0) {
              return scope.nodeClicked(e);
            }
          });
        } else if (attrs.graphtype === "committee") {
          scope.graphType = "committee";
          scope.committeeBarExists = true;
        }
      });
      scope.toggleCommitteeBar = function(exists) {
        return scope.committeeBarExists = exists;
      };
      scope.changeGraphView = function() {
        var department, _i, _len, _ref;
        if (attrs.graphtype === "explorative") {
          attrs.graphtype = "committee";
          scope.graphType = "committee";
          element.unbind("click");
          scope.toggleCommitteeBar(true);
        } else if (attrs.graphtype === "committee") {
          scope.toggleCommitteeBar(false);
          scope.graphType = "explorative";
          attrs.graphtype = "explorative";
          scope.activeCommittee = {
            id: null,
            members: [],
            departments: []
          };
          scope.toggleSchools(false);
          element.bind("click", function(e) {
            var nodeClicked;
            nodeClicked = e.toElement.attributes.identifier;
            if (nodeClicked !== void 0) {
              return scope.nodeClicked(e);
            }
          });
          _ref = scope.activeCommittee.departments;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            department = _ref[_i];
            scope.departmentClicked(department);
          }
        }
      };
      scope.nodeClicked = function(e) {
        var nodeId, nodeType;
        if (e.shiftKey === true) {
          nodeType = e.target.className.baseVal;
          nodeId = e.target.attributes.identifier.value;
          if (nodeType === "department_node" || nodeType === "department_node_label") {
            return scope.departmentClicked(nodeId);
          } else if (nodeType === "school_node" || nodeType === "school_node_label") {
            return scope.schoolClicked(nodeId);
          } else if (nodeType === "user_node" || nodeType === "user_node_label") {
            return scope.userClicked(nodeId);
          }
        }
      };
      scope.toggleSchools = function(expand) {
        var department, properties, school, _ref, _results;
        _ref = scope.schools;
        _results = [];
        for (school in _ref) {
          properties = _ref[school];
          if (expand === true && scope.isSchoolActive(school) !== true) {
            _results.push(scope.schoolClicked(school));
          } else if (expand !== true && scope.isSchoolActive(school) === true) {
            scope.schoolClicked(school);
            if (scope.activeCommittee.id !== null) {
              _results.push((function() {
                var _i, _len, _ref1, _results1;
                _ref1 = scope.activeCommittee.departments;
                _results1 = [];
                for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                  department = _ref1[_i];
                  if (scope.isDepartmentActive(department) !== true) {
                    _results1.push(scope.departmentClicked(department));
                  } else {
                    _results1.push(void 0);
                  }
                }
                return _results1;
              })());
            } else {
              _results.push(void 0);
            }
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      scope.pinSchools = function(pin) {
        var properties, school, _ref, _results;
        _ref = scope.schools;
        _results = [];
        for (school in _ref) {
          properties = _ref[school];
          _results.push(scope.g.pinNode(school));
        }
        return _results;
      };
      scope.toggleSettings = function(show) {
        scope.showSettings = show;
      };
      scope.committeeClicked = function(committee) {
        var department, info, location, name, position, properties, school, workLocations, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
        if (scope.activeCommittee.id !== null) {
          scope.updateGraph({
            type: "committee_links",
            members: scope.activeCommittee.members
          }, false);
        }
        scope.activeCommittee.members = [];
        scope.activeCommittee.departments = [];
        scope.activeCommittee.id = committee.committee_name;
        _ref = scope.committees[committee.id].people;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          name = _ref[_i];
          scope.activeCommittee.members.push(name);
          workLocations = scope.workInfo[name].locations;
          for (location in workLocations) {
            position = workLocations[location];
            if (location.indexOf("School") === -1 && scope.isFoundIn(location, scope.activeCommittee.departments) !== true) {
              scope.activeCommittee.departments.push(location);
            }
          }
        }
        _ref1 = scope.schools;
        for (school in _ref1) {
          properties = _ref1[school];
          _ref2 = properties.standardizedDepartments;
          for (department in _ref2) {
            info = _ref2[department];
            if (scope.isDepartmentActive(department) === true) {
              scope.departmentClicked(department);
            }
          }
        }
        _ref3 = scope.committees[committee.id].people;
        for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
          name = _ref3[_j];
          workLocations = scope.workInfo[name].locations;
          for (location in workLocations) {
            position = workLocations[location];
            if (location.indexOf("School") === -1) {
              if (scope.isDepartmentActive(location) === false) {
                scope.departmentClicked(location);
              }
            }
          }
        }
        scope.updateGraph({
          type: "committee_links",
          members: scope.activeCommittee.members
        }, true);
      };
      scope.isFoundIn = function(term, array) {
        return array.indexOf(term) !== -1;
      };
      scope.schoolClicked = function(school) {
        var addDepartments, selectedSchool;
        addDepartments = scope.isSchoolActive(school);
        scope.updateActiveSchools(school);
        selectedSchool = scope.schools[school];
        return scope.updateGraph(selectedSchool, !addDepartments);
      };
      scope.departmentClicked = function(department) {
        var addPeople, getLinkedSchool, linkedSchool, location, locs, position, properties, selectedDepartment, username, _ref, _ref1, _ref2;
        getLinkedSchool = (function(_this) {
          return function() {
            var d, school, schoolProperties, _i, _len, _ref, _ref1;
            _ref = scope.schools;
            for (school in _ref) {
              schoolProperties = _ref[school];
              _ref1 = schoolProperties.departments;
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                d = _ref1[_i];
                if (d === department) {
                  return school;
                }
              }
            }
          };
        })(this);
        linkedSchool = getLinkedSchool();
        addPeople = !scope.isDepartmentActive(department);
        if (addPeople === true && scope.isSchoolActive(linkedSchool) === false) {
          scope.schoolClicked(linkedSchool);
        }
        if (addPeople === false) {
          scope.activeDepartments.splice(scope.activeDepartments.indexOf(department), 1);
        } else {
          scope.activeDepartments.push(department);
        }
        selectedDepartment = scope.schools[linkedSchool].standardizedDepartments[department];
        if (scope.graphType === "explorative") {
          _ref = selectedDepartment.standardizedUsers;
          for (username in _ref) {
            properties = _ref[username];
            locs = Object.keys(scope.workInfo[username].locations);
            if (locs.length > 2) {
              properties.fill = "orange";
            } else if (locs.length === 2) {
              if (locs[0].indexOf("School") !== -1 && locs[1].indexOf("School") !== -1) {
                properties.fill = "yellow";
              } else {
                properties.fill = "#4568A3";
              }
            } else {
              properties.fill = "#4568A3";
            }
          }
        } else if (scope.graphType === "committee") {
          _ref1 = selectedDepartment.standardizedUsers;
          for (username in _ref1) {
            properties = _ref1[username];
            _ref2 = scope.workInfo[username].locations;
            for (location in _ref2) {
              position = _ref2[location];
              if (scope.isFoundIn(username, scope.activeCommittee.members)) {
                properties.fill = "orange";
              } else if (scope.isFoundIn(location, scope.activeCommittee.departments)) {
                properties.fill = "#124654";
              }
            }
          }
        }
        return scope.updateGraph(selectedDepartment, addPeople);
      };
      scope.userClicked = function(user) {
        var location, position, schoolsArray, _ref, _results;
        schoolsArray = Object.keys(scope.schools);
        _ref = scope.workInfo[user].locations;
        _results = [];
        for (location in _ref) {
          position = _ref[location];
          if (schoolsArray.indexOf(location) !== -1) {
            if (scope.isSchoolActive(location) !== true) {
              _results.push(scope.schoolClicked(location));
            } else {
              _results.push(void 0);
            }
          } else if (scope.isDepartmentActive(location) !== true) {
            _results.push(scope.departmentClicked(location));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      /*
      Description: We do not know or need to know whether the location is a department or school,
       only whether or not the current location is active
      Input: [String] location - location name
       */
      scope.isLocationActive = function(location) {
        return scope.isSchoolActive(location) || scope.isDepartmentActive(location);
      };

      /*
      Description: Checking to see if school is active
      Input: [String] school : name of the school
       */
      scope.isSchoolActive = function(school) {
        return __indexOf.call(scope.activeSchools, school) >= 0;
      };

      /*
      Description: Checking to see if department is active
      Input: [String] school : name of the department
       */
      scope.isDepartmentActive = function(department) {
        return __indexOf.call(scope.activeDepartments, department) >= 0;
      };
      scope.updateActiveSchools = function(school) {
        var dep, _i, _len, _ref, _results;
        if (__indexOf.call(scope.activeSchools, school) >= 0) {
          scope.activeSchools.splice(scope.activeSchools.indexOf(school), 1);
          _ref = scope.schools[school].departments;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            dep = _ref[_i];
            if (scope.isDepartmentActive(dep) === true) {
              _results.push(scope.departmentClicked(dep));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        } else {
          return scope.activeSchools.push(school);
        }
      };
      scope.updateGraph = function(nodes, add) {
        scope.g.updateGraph(nodes, add);
      };
      return scope.toggleDepartmentLabels = function() {
        return $scope.activeDepartmentLabels = !$scope.activeDepartmentLabels;
      };
    };
    return {
      restrict: "E",
      replace: true,
      templateUrl: "partials/graph.html",
      link: linker
    };
  });

  angular.module("extra_information", []).directive("extraInformation", function() {
    var linker;
    linker = function(scope, element, attrs) {
      return scope.pinSchools = "Schools Pinned";
    };
    return {
      restrict: "E",
      templateUrl: "partials/extra_info.html",
      replace: true
    };
  });

}).call(this);

//# sourceMappingURL=ICCVCtrl.js.map
