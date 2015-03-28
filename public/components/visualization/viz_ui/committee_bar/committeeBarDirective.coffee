ICCVCommitteeBar = angular.module("iccv.committeeBar",[])

ICCVCommitteeBar.directive("committeeBar",() ->
  restrict   : "E"
  require    :"^iccv.graph"
  templateUrl: "components/visualization/viz_ui/committee_bar/committee_bar.html"
  replace    : true
)