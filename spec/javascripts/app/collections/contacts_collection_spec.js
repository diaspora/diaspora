describe("app.collections.Contacts", function(){
  beforeEach(function(){
    this.collection = new app.collections.Contacts();
  });

  describe("comparator", function() {
    beforeEach(function(){
      this.aspect = new app.models.Aspect({id: 42, name: "cats"});
      this.con1 = new app.models.Contact({
                    person: { name: "aaa" },
                    aspect_memberships: []
                  });
      this.con2 = new app.models.Contact({
                    person: { name: "aaa" },
                    aspect_memberships: [{id: 23, aspect: this.aspect}]
                  });
      this.con3 = new app.models.Contact({
                    person: { name: "zzz" },
                    aspect_memberships: [{id: 23, aspect: this.aspect}]
                  });
    });

    it("should compare the username if app.aspect is not present", function() {
      expect(this.collection.comparator(this.con1, this.con3)).toBeLessThan(0);
    });

    it("should compare the aspect memberships if app.aspect is present", function() {
      app.aspect = this.aspect;
      expect(this.collection.comparator(this.con1, this.con3)).toBeGreaterThan(0);
    });

    it("should compare the username if the contacts have equal aspect memberships", function() {
      app.aspect = this.aspect;
      expect(this.collection.comparator(this.con2, this.con3)).toBeLessThan(0);
    });
  });
});
