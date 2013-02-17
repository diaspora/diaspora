
describe("app.views.AspectMembership", function(){
  beforeEach(function() {
    // mock a dummy aspect dropdown
    this.person = factory.author({name: "My Name"});
    spec.content().html(
      '<div class="aspect_membership dropdown">'+
      '  <div class="button toggle">The Button</div>'+
      '  <ul class="dropdown_list" data-person-short-name="'+this.person.name+'" data-person_id="'+this.person.id+'">'+
      '    <li data-aspect_id="10">Aspect 10</li>'+
      '    <li data-membership_id="99" data-aspect_id="11" class="selected">Aspect 11</li>'+
      '    <li data-aspect_id="12">Aspect 12</li>'+
      '  </ul>'+
      '</div>'
    );

    this.view = new app.views.AspectMembership();
  });

  it('attaches to the aspect selector', function(){
    spyOn($.fn, 'on');
    view = new app.views.AspectMembership();

    expect($.fn.on).toHaveBeenCalled();
  });

  context('adding to aspects', function() {
    beforeEach(function() {
      this.newAspect = spec.content().find('li:eq(0)');
      this.newAspectId = 10;
    });

    it('calls "addMembership"', function() {
       spyOn(this.view, "addMembership");
       this.newAspect.trigger('click');

       expect(this.view.addMembership).toHaveBeenCalledWith(this.person.id, this.newAspectId);
    });

    it('tries to create a new AspectMembership', function() {
      spyOn(app.models.AspectMembership.prototype, "save");
      this.view.addMembership(1, 2);

      expect(app.models.AspectMembership.prototype.save).toHaveBeenCalled();
    });

    it('displays an error when it fails', function() {
      spyOn(this.view, "_displayError");
      spyOn(app.models.AspectMembership.prototype, "save").andCallFake(function() {
        this.trigger('error');
      });

      this.view.addMembership(1, 2);

      expect(this.view._displayError).toHaveBeenCalledWith('aspect_dropdown.error');
    });
  });

  context('removing from aspects', function(){
    beforeEach(function() {
      this.oldAspect = spec.content().find('li:eq(1)');
      this.oldMembershipId = 99;
    });

    it('calls "removeMembership"', function(){
      spyOn(this.view, "removeMembership");
      this.oldAspect.trigger('click');

      expect(this.view.removeMembership).toHaveBeenCalledWith(this.oldMembershipId);
    });

    it('tries to destroy an AspectMembership', function() {
      spyOn(app.models.AspectMembership.prototype, "destroy");
      this.view.removeMembership(1);

      expect(app.models.AspectMembership.prototype.destroy).toHaveBeenCalled();
    });

    it('displays an error when it fails', function() {
      spyOn(this.view, "_displayError");
      spyOn(app.models.AspectMembership.prototype, "destroy").andCallFake(function() {
        this.trigger('error');
      });

      this.view.removeMembership(1);

      expect(this.view._displayError).toHaveBeenCalledWith('aspect_dropdown.error_remove');
    });
  });

  context('summary text in the button', function() {
    beforeEach(function() {
      this.btn = spec.content().find('div.button.toggle');
      this.btn.text(""); // reset
      this.view.dropdown = spec.content().find('ul.dropdown_list');
    });

    it('shows "no aspects" when nothing is selected', function() {
      spec.content().find('li[data-aspect_id]').removeClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Diaspora.I18n.t('aspect_dropdown.toggle.zero'));
    });

    it('shows "all aspects" when everything is selected', function() {
      spec.content().find('li[data-aspect_id]').addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Diaspora.I18n.t('aspect_dropdown.all_aspects'));
    });

    it('shows the name of the selected aspect ( == 1 )', function() {
      var list = spec.content().find('li[data-aspect_id]');
      list.removeClass('selected'); // reset
      list.eq(1).addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(list.eq(1).text());
    });

    it('shows the number of selected aspects ( > 1)', function() {
      var list = spec.content().find('li[data-aspect_id]');
      list.removeClass('selected'); // reset
      $([list.eq(1), list.eq(2)]).addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Diaspora.I18n.t('aspect_dropdown.toggle', { 'count':2 }));
    });
  });
});
