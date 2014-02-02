describe("app.views.Hovercard", function(){
  beforeEach(function(){
    var html = '<a href="/people/1402141b454f7fc8" class="author-name hovercardable">'+
      '<div id="hovercard_container" style=" display: none;">'+
        '<div id="hovercard">'+
          '<img class="avatar" src="https://localhost/image.jpg">'+
          '<h4>'+
            '<span class="person" href="/people/1402141b454f7fc8">Amalthea</span>'+ // can not be an <a> don#t know why
          '</h4>'+
          '<p class="handle">amaletha@localhost</p>'+
          '<div id="hovercard_dropdown_container"></div>'+
          '<div class="hovercard_footer">'+
            '<div class="footer_container">'+
              '<div class="hashtags"></div>'+
            '</div>'+
          '</div>'+
        '</div>'+      
      '</div>'+
      '<img src="https://localhost/image.jpg" class="avatar small" data-original-title="Amalthea">'+
      '<div class="tooltip fade top in" style="top: 56px; left: 890px; display: block;">'+
        '<div class="tooltip-arrow"></div>'+
        '<div class="tooltip-inner">Amalthea</div>'+
      '</div>'+
    '</a>';
    $('body').append(html);
    this.view = new app.views.Hovercard();
    this.view.initialize();
  });

  afterEach(function() {
    $('.hovercardable').empty();
    $('.hovercardable').remove();  
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

