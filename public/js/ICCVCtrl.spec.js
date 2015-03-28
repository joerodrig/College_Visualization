/**
 * @module test.ICCV
 * @name ICCVCtrl
 * @description
 * Tests for ICCVCtrl under ICCV
 * _Enter the test description._
 * */


describe('Controller: ICCV.ICCVCtrl', function () {
    var $compile,
        $rootScope;
    // load the controller's module
    beforeEach(module('ICCV',['ngAnimate']));

    //Store ref. to $rootscope and $compile so
    //they are available to all tests in this desc. block
    beforeEach(inject(function(_$compile_,_$rootScope_){
        $compile   = _$compile_;
        $rootScope = _$rootScope_;
    }));


});
