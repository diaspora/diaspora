describe("app.models.User", function(){
  beforeEach(function(){
    this.user = new app.models.User({})
  });

  describe("authenticated", function(){
    it("should be true if ID is nil", function(){
      expect(this.user.authenticated()).toBeFalsy();
    });

    it('should be true if ID is set', function(){
      this.user.set({id : 1})
      expect(this.user.authenticated()).toBeTruthy();
    });

  });
});

