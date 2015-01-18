/**
 * @module test.ICCV
 * @name ICCVCtrl
 * @description
 * Tests for ICCVCtrl under ICCV
 * _Enter the test description._
 * */


describe('Controller: ICCV.ICCVCtrl', function () {

    // load the controller's module
    beforeEach(module('ICCV'));

    var ctrl,
        scope;

    // Initialize the controller and a mock scope
    beforeEach(inject(function ($controller, $rootScope) {
        scope = $rootScope.$new();
        ctrl = $controller('ICCVCtrl', {
            $scope: scope
        });
    }));

    it('should be defined', function () {
        expect(ctrl).toBeDefined();
    });
});
