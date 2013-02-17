describe("app.models.Aspect", function(){
  describe("#toggleSelected", function(){
    it("should select the aspect", function(){
      this.aspect = new app.models.Aspect({ name: 'John Doe', selected: false });
      this.aspect.toggleSelected();
      expect(this.aspect.get("selected")).toBeTruthy();
    });

    it("should deselect the aspect", function(){
      this.aspect = new app.models.Aspect({ name: 'John Doe', selected: true });
      this.aspect.toggleSelected();
      expect(this.aspect.get("selected")).toBeFalsy();
    });
  });
});
