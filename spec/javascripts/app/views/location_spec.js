describe("app.views.Location", function(){
  beforeEach(function(){
    OSM.Locator = function(){return { getAddress:function(){}}};

    this.view = new app.views.Location();
  });

  describe("When it gets instantiated", function(){
    it("creates #location_address", function(){

      expect($("#location_address")).toBeTruthy();
      expect($("#location_coords")).toBeTruthy();
      expect($("#hide_location")).toBeTruthy();
    });
  });
});
