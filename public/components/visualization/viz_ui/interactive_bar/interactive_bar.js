// Generated by CoffeeScript 1.8.0
(function() {
  var ICCVInteractiveBar;

  ICCVInteractiveBar = angular.module("iccv.interactiveBar", []);

  ICCVInteractiveBar.directive('interactiveBar', function() {
    return {
      restrict: "E",
      require: "^iccv.graph",
      templateUrl: "components/visualization/viz_ui/interactive_bar/interactive_bar.html",
      replace: true
    };
  });

}).call(this);

//# sourceMappingURL=interactive_bar.js.map