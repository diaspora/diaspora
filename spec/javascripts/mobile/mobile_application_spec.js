describe("Diaspora.Mobile", function(){
  describe("initialize", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_nsfw_post");
      spyOn(window, "autosize");
    });

    it("calls autosize for textareas", function(){
      Diaspora.Mobile.initialize();
      expect(window.autosize).toHaveBeenCalled();
      expect(window.autosize.calls.mostRecent().args[0].is($("textarea"))).toBe(true);
    });

    it("deactivates shield", function(){
      Diaspora.Mobile.initialize();
      var $shield = $(".stream-element").first();
      expect($shield).toHaveClass("shield-active");
      $shield.find(".shield a").click();
      expect($shield).not.toHaveClass("shield-active");
    });
  });
});
