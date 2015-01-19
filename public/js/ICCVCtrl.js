/**
 * @ngdoc controller
 * @name ICCV.controller:ICCVCtrl
 *
 * @description
 *
 *
 * @requires $scope
 * */

var ICCVApp = angular.module('ICCV', ['extra_information']);

ICCVApp.controller('ICCVCtrl', ['$scope', '$http', function ($scope, $http) {
    $scope.activeGroupName;
    $scope.showExtraInfo    = true;
    $scope.positionCount    = [];
    $scope.departmentCount  = [];
    $scope.committees = [
        {
            id: "C1",
            committee_name: "Committee One",
            people: ["cmckenzie", "jives", "ebleicher", "chaltom"]
        },
        {
            id: "C3",
            committee_name: "CS Committee",
            people: ["aerkan", "dturnbull", "barr", "nprestopnik", "pdickson", "tdragon"]
        },
        {
            id: "C4",
            committee_name: "Another Committee",
            people: ["jhilton", "euell", "ebleicher", "ppospisil"]
        }
    ];

    // [asynchronously] Retrieving work info
    $scope.workInfo = $http.get('json/work_info.json').
        success(function (data, status, headers, config) {
            $scope.workInfo = data;
        });

    // [asynchronously] Retrieving school & department info
    $scope.schools = $http.get('json/schools_departments.json').
        success(function (data,status,headers,config) {
            $scope.schools = data;
        });
}]);

/**
 * Committee Graph directive
 */
ICCVApp.directive('graph', function ($http, $q) {
    function linker(scope, element, attrs) {
        //Initialize graph(s) once required information has successfully loaded
        $q.all([scope.workInfo,scope.schools]).then(function () {
            console.log("Handling Information");
            var options = {container: attrs.container},
                loadedData = {workInfo: scope.workInfo, schoolLinker: scope.schools};
            scope.g = new CommitteeGraph.initialize(element[0], loadedData, options);
        });

        //UI changes
        scope.toggleExtraInfo = function TEI(show) {
            scope.showExtraInfo = show;
        };

        scope.committeeClicked = function (committee) {
            scope.setActiveGroup( committee.committee_name );

            var membersInfo = [];
            $.each(committee.people, function (key, name) {
                membersInfo.push({name: name, workInfo: scope.workInfo[name]});
            });

            scope.loadMembers(membersInfo);
            scope.updateCounts(membersInfo);
        };

        scope.schoolClicked = function(school,data){
            scope.setActiveGroup(school);
            var membersInfo = [];
            $.each(scope.workInfo, function (employeeName,info) {
                $.each(info,function(key2,work){
                    if (scope.schools[school].departments.indexOf(work.location) !== -1  ) {
                        membersInfo.push({name:employeeName, workInfo:scope.workInfo[employeeName]});
                        return;
                    }
                });
            });

            scope.loadMembers(membersInfo);
            scope.updateCounts(membersInfo);

        }

        scope.loadMembers =  function loadMembers(membersInfo) {
            scope.g.updateGraph(membersInfo);
        }

        scope.updateCounts = function updateCounts(membersInfo) {
            scope.positionCount = [];
            scope.departmentCount = [];
            $.each(membersInfo, function (key, user) {
                $.each(user.workInfo, function (key, workInfo) {
                    if (scope.positionCount.length === 0) {
                        scope.positionCount.push({position: workInfo.position, count: 1});
                    }
                    if (scope.departmentCount.length === 0) {
                        scope.departmentCount.push({department: workInfo.location, count: 1});
                    }
                    for (var i = 0; i < scope.positionCount.length; i++) {
                        if (scope.positionCount[i].position === workInfo.position) {
                            scope.positionCount[i].count++;
                            break;
                        } else if (i == scope.positionCount.length - 1) {
                            scope.positionCount.push({position: workInfo.position, count: 1});
                            break;
                        }
                    }

                    for (var j = 0; j < scope.departmentCount.length; j++) {
                        if (scope.departmentCount[j].department === workInfo.location) {
                            scope.departmentCount[j].count++;
                            break;
                        } else if (j == scope.departmentCount.length - 1) {
                            scope.departmentCount.push({department: workInfo.location, count: 1});
                            break;
                        }
                    }
                });
            });
        }



        scope.setActiveGroup = function(name){
            scope.activeGroupName = name;
        }

    }
    return {
        restrict: 'E',
        replace: true,
        templateUrl: 'partials/graph.html',
        link: linker
    };
});

angular.module('extra_information', [])
    .directive('extraInformation', function () {
        return {
            restrict: 'E',
            templateUrl: 'partials/extra_info.html',
            replace:true
        };
    });