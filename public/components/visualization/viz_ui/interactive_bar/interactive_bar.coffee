ICCVInteractiveBar = angular.module("iccv.interactiveBar",[])

ICCVInteractiveBar.directive('interactiveBar', () ->
  return {
  restrict    : "E"
  require     : "^iccv.graph"
  templateUrl : "components/visualization/viz_ui/interactive_bar/interactive_bar.html"
  replace     : true
  }
)
