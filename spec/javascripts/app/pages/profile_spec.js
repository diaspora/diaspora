
describe("app.pages.Profile", function() {
  beforeEach(function() {
    this.model = factory.person();
    spyOn(this.model, 'block').and.returnValue($.Deferred());
    spyOn(this.model, 'unblock').and.returnValue($.Deferred());
    this.view = new app.pages.Profile({model: this.model});
  });

  context("#blockPerson", function() {
    it("calls person#block", function() {
      spyOn(window, 'confirm').and.returnValue(true);
      this.view.blockPerson();
      expect(this.model.block).toHaveBeenCalled();
    });
  });

  context("#unblockPerson", function() {
    it("calls person#unblock", function() {
      this.view.unblockPerson();
      expect(this.model.unblock).toHaveBeenCalled();
    });
  });
});
