describe("app.views.Hovercard", function(){
  beforeEach(function(){
    loadFixtures('/spec/fixtures/link_with_hovercard.html'); 
    this.view = new app.views.Hovercard();
  });

  afterEach(function() {
    this.view = new app.views.Hovercard();
    this.view.initialize();
  });

  afterEach(function() {
  });

  describe("._positionHovercard", function(){
    it("parent is on left side of page", function() {
      this.view._positionHovercard();
      expect($(this.view.el).css("left")).toBe('0px')
    })

    it("parent is on right side of page", function() {
      $('.hovercardable').css('float','right');
      this.view._positionHovercard();
      expect($(this.view.el).css("left")).toBe($(this.view.el).parent().position().left-$(this.view.el).width()+'px');
    })
  })

})

