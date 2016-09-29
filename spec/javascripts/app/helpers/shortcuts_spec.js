describe("app.helpers.Shortcuts", function() {
  it("calls the function when the event has been fired outside of an input field", function() {
    var spy = jasmine.createSpy();
    spec.content().append("<div class='hotkey-div'></div>");
    app.helpers.Shortcuts("keydown", spy);
    $(".hotkey-div").trigger("keydown");
    expect(spy).toHaveBeenCalled();
  });

  it("doesn't call the function when the event has been fired in an input field", function() {
    var spy = jasmine.createSpy();
    spec.content().append("<textarea class='hotkey-textarea'></textarea>");
    app.helpers.Shortcuts("keydown", spy);
    $(".hotkey-textarea").trigger("keydown");
    expect(spy).not.toHaveBeenCalled();
  });
});
