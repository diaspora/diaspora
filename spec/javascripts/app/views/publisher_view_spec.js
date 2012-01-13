describe("app.views.Publisher", function() {
  beforeEach(function() {
    // should be jasmine helper
    loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    spec.loadFixture("aspects_index");
    this.view = new app.views.Publisher();
  });

  describe("#open", function() {
    it("removes the 'closed' class from the publisher element", function() {
      expect($(this.view.el)).toHaveClass("closed");
      this.view.open($.Event());
      expect($(this.view.el)).not.toHaveClass("closed");
    });
  });

  describe("#close", function() {
    it("removes the 'active' class from the publisher element", function(){
      $(this.view.el).removeClass("closed");

      expect($(this.view.el)).not.toHaveClass("closed");
      this.view.close($.Event());
      expect($(this.view.el)).toHaveClass("closed");
    })
  });

  describe("#clear", function() {
    it("calls close", function(){
      spyOn(this.view, "close");

      this.view.clear($.Event());
      expect(this.view.close);
    })

    it("clears all textareas", function(){
      _.each(this.view.$("textarea"), function(element){
        $(element).val('this is some stuff');
        expect($(element).val()).not.toBe("");
      });

      this.view.clear($.Event());

      _.each(this.view.$("textarea"), function(element){
        expect($(element).val()).toBe("");
      });
    })

    it("removes all photos from the dropzone area", function(){
      var self = this;
      _.times(3, function(){
        self.view.$("#photodropzone").append($("<li>"))
      });

      expect(this.view.$("#photodropzone").html()).not.toBe("");
      this.view.clear($.Event());
      expect(this.view.$("#photodropzone").html()).toBe("");
    })
  });
});
