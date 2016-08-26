describe("app.views.FlashMessages", function(){
  var flashMessages = new app.views.FlashMessages();

  describe("flash", function(){
    it("call _flash with correct parameters", function() {
      spyOn(flashMessages, "_flash");
      flashMessages.success("success!");
      expect(flashMessages._flash).toHaveBeenCalledWith("success!", false);
      flashMessages.error("error!");
      expect(flashMessages._flash).toHaveBeenCalledWith("error!", true);
    });
  });

  describe("render", function(){
    beforeEach(function(){
      spec.content().html("<div class='flash-container'/>");
      flashMessages = new app.views.FlashMessages({ el: $(".flash-container") });
    });

    it("renders a success message", function(){
      flashMessages.success("success!");
      expect(flashMessages.$(".flash-body")).toHaveClass("expose");
      expect($(".flash-message")).toHaveClass("alert-success");
      expect($(".flash-message").text().trim()).toBe("success!");
    });
    it("renders an error message", function(){
      flashMessages.error("error!");
      expect(flashMessages.$(".flash-body")).toHaveClass("expose");
      expect($(".flash-message")).toHaveClass("alert-danger");
      expect($(".flash-message").text().trim()).toBe("error!");
    });
  });
});
