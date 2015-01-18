/**
 * @ngdoc controller
 * @name ICCV.controller:ICCVCtrl
 *
 * @description
 * _Please update the description and dependencies._
 *
 * @requires $scope
 * */

var ICCVApp = angular.module('ICCV', ['extra_information']);

ICCVApp.controller('ICCVCtrl', ['$scope', '$http', function ($scope, $http) {
    $scope.workInfo;
    $scope.activeCommittee;
    $scope.showExtraInfo = true;
    $scope.positionCount = [];
    $scope.departmentCount = [];
    $scope.committees = [
        {
            id: "C1",
            committee_name: "Committee One",
            people: ["cmckenzie", "jives", "ebleicher", "chaltom"]
        },
        {
            id: "C2",
            committee_name: "Committee Two",
            people: ["cmckenzie", "jives", "ebleicher", "chaltom"]
        },
        {
            id: "C3",
            committee_name: "Computer Science",
            people: ["aerkan", "dturnbull", "barr", "nprestopnik", "pdickson", "tdragon"]
        },
        {
            id: "C4",
            committee_name: "Committee Four",
            people: ["jhilton", "euell", "ebleicher", "ppospisil"]
        }
    ];
    $scope.schools = [
        {
            short_name: "Humanities and Sciences",
            full_name: "School of Humanities and Sciences"
        },
        {
            short_name: "Music",
            full_name: "School of Music"

        },
        {
            short_name:"Health Sciences and Human Performance",
            full_name:"School of Health Sciences and Human Performance"
        },
        {
            short_name:"Park School of Communications",

        }
        "", "Roy H. Park School of Communications"
    ]


    //Demo Information
    /*
     randomNum = function generateRandomNumber() {
     return Math.floor(Math.random() * (10 - 1 + 1) + 1);
     }

     $scope.positionCount = [
     {
     position: "Instructor", count: randomNum()
     },
     {
     position: "Dean", count: randomNum()
     },
     {
     position: "Faculty", count: randomNum()
     },
     {
     position: "Associate Professor", count: randomNum()
     },

     ];

     $scope.departmentCount = [
     {
     department: "Department of Mathematics", count: randomNum()
     },
     {
     department: "School of Humanities and Sciences", count: randomNum()
     },
     {
     department: "Department of Writing", count: randomNum()
     },
     {
     department: "Honors Program", count: randomNum()
     },
     ]; */
}]);


ICCVApp.directive('committeeGraph', function ($http) {
    function linker(scope, element, attrs) {
        $http.get('js/work_info.json').
            success(function (data, status, headers, config) {
                console.log("Successfully Retrieved Work Info");
                scope.workInfo = data;
                var options = {container: attrs.container};
                scope.g = new CommitteeGraph.initialize(element[0], scope.workInfo, options);
            });

        //UI
        scope.toggleExtraInfo = function TEI(show) {
            scope.showExtraInfo = show;
        }

        scope.committeeClicked = function (committee) {
            var membersInfo = [];

            $.each(committee.people, function (key, name) {
                membersInfo.push({name: name, workInfo: scope.workInfo[name]});
            });

            scope.activeCommittee = committee.id;
            scope.activeCommitteeName = committee.committee_name;
            loadMembers(membersInfo);
            updateCounts(membersInfo);

            function loadMembers(membersInfo) {
                scope.g.updateGraph(membersInfo);
            }

            function updateCounts(membersInfo) {
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

                        for (var i = 0; i < scope.departmentCount.length; i++) {
                            if (scope.departmentCount[i].department === workInfo.location) {
                                scope.departmentCount[i].count++;
                                break;
                            } else if (i == scope.departmentCount.length - 1) {
                                scope.departmentCount.push({department: workInfo.location, count: 1});
                                break;
                            }
                        }
                    });
                });
            }
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
            templateUrl: 'partials/extra_info.html'
        };
    });