describe("app.models.AspectSelection", function(){
  describe("#toggleSelected", function(){
    it("should select the aspect", function(){
      this.aspect = new app.models.AspectSelection({ name: "John Doe", selected: false });
      this.aspect.toggleSelected();
      expect(this.aspect.get("selected")).toBeTruthy();
    });

    it("should deselect the aspect", function(){
      this.aspect = new app.models.AspectSelection({ name: "John Doe", selected: true });
      this.aspect.toggleSelected();
      expect(this.aspect.get("selected")).toBeFalsy();
    });
  });
});
