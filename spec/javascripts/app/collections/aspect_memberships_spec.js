describe("app.collections.AspectMemberships", function() {
  beforeEach(function() {
    this.models = [factory.aspectMembershipAttrs(), factory.aspectMembershipAttrs(), factory.aspectMembershipAttrs()];
    this.collection = new app.collections.AspectMemberships(this.models);
  });

  describe("#findByAspectId", function() {
    it("finds a model in collection", function() {
      var model = this.collection.findByAspectId(this.models[1].aspect.id);
      expect(model.get("id")).toEqual(this.models[1].id);
    });

    it("returns undefined when nothing found", function() {
      expect(this.collection.findByAspectId(factory.id.next())).toEqual(undefined);
    });
  });
});
