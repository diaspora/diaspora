describe("Diaspora.Mobile.Alert", function() {
  describe("_flash", function() {
    beforeEach(function() {
      spec.content().html("<div id='flash-messages'></div>");
    });

    it("appends an alert to the #flash-messages div", function() {
      Diaspora.Mobile.Alert._flash("Oh snap! You got an error!", "error-class");
      expect($("#flash-messages .alert")).toHaveClass("alert-error-class");
      expect($("#flash-messages .alert").text()).toBe("Oh snap! You got an error!");
    });
  });

  describe("success", function() {
    it("calls _flash", function() {
      spyOn(Diaspora.Mobile.Alert, "_flash");
      Diaspora.Mobile.Alert.success("Awesome!");
      expect(Diaspora.Mobile.Alert._flash).toHaveBeenCalledWith("Awesome!", "success");
    });
  });

  describe("error", function() {
    it("calls _flash", function() {
      spyOn(Diaspora.Mobile.Alert, "_flash");
      Diaspora.Mobile.Alert.error("Oh noez!");
      expect(Diaspora.Mobile.Alert._flash).toHaveBeenCalledWith("Oh noez!", "danger");
    });
  });
});
