/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Publisher", function() {

  Publisher.open = function(){ this.form().removeClass("closed"); }

  describe("toggleCounter", function(){
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
    });

    it("gets called in when you toggle service icons", function(){
      spyOn(Publisher, 'createCounter');
      Publisher.toggleServiceField($(".service_icon").first());
      expect(Publisher.createCounter).toHaveBeenCalled();
    });

    it("removes the .counter span", function(){
      spyOn($.fn, "remove");
      Publisher.createCounter($(".service_icon").first());
      expect($.fn.remove).toHaveBeenCalled();
    });
  });

  describe("bindAspectToggles", function() {
    beforeEach( function(){
      spec.loadFixture('status_message_new');
      Publisher.open();
    });

    it('gets called on initialize', function(){
      spyOn(Publisher, 'bindAspectToggles');
      Publisher.initialize();
      expect(Publisher.bindAspectToggles).toHaveBeenCalled();
    });

    it('correctly initializes an all_aspects state', function(){
      Publisher.initialize();

      expect($("#publisher .dropdown .dropdown_list li.radio").first().hasClass("selected")).toBeFalsy();
      expect($("#publisher .dropdown .dropdown_list li.radio").last().hasClass("selected")).toBeTruthy();

      $.each($("#publihser .dropdown .dropdown_list li.aspect_selector"), function(index, element){
        expect($(element).hasClass("selected")).toBeFalsy();
      });
    });

    it('toggles selected only on the clicked icon', function(){
      Publisher.initialize();

      $("#publisher .dropdown .dropdown_list li.aspect_selector").last().click();

      $.each($("#publisher .dropdown .dropdown_list li.radio"), function(index, element){
        expect($(element).hasClass("selected")).toBeFalsy();
      });

      expect($("#publisher .dropdown .dropdown_list li.aspect_selector").first().hasClass("selected")).toBeFalsy();
      expect($("#publisher .dropdown .dropdown_list li.aspect_selector").last().hasClass("selected")).toBeTruthy();
    });

    it('calls toggleAspectIds with the clicked element', function(){
      spyOn(Publisher, 'toggleAspectIds');
      Publisher.bindAspectToggles();
      var aspectBadge = $("#publisher .dropdown .dropdown_list li").last();
      aspectBadge.click();
      expect(Publisher.toggleAspectIds.mostRecentCall.args[0].get(0)).toEqual(aspectBadge.get(0));
    });
  });

  describe('toggleAspectIds', function(){
    beforeEach( function(){
      spec.loadFixture('status_message_new');
      li = $("<li data-aspect_id=42></li>");
    });

    it('adds a hidden field to the form if there is not one already', function(){
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);
      expect($('#publisher [name="aspect_ids[]"]').last().attr('value')).toBe('all_aspects');
      Publisher.toggleAspectIds(li);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);
      expect($('#publisher [name="aspect_ids[]"]').last().attr('value')).toBe('42');
    });

    it('removes the hidden field if its already there', function() {
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);

      Publisher.toggleAspectIds(li);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);

      Publisher.toggleAspectIds(li);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(0);
    });

    it('does not remove a hidden field with a different value', function() {
      var li2 = $("<li data-aspect_id=99></li>");

      Publisher.toggleAspectIds(li);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);

      Publisher.toggleAspectIds(li2);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(2);
    });
  });

  describe("bindServiceIcons", function() {
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
    });

    it('gets called on initialize', function(){
      spyOn(Publisher, 'bindServiceIcons');
      Publisher.initialize();
      expect(Publisher.bindServiceIcons).toHaveBeenCalled();
    });

    it('toggles dim only on the clicked icon', function(){
      expect($(".service_icon#facebook").hasClass("dim")).toBeTruthy();
      expect($(".service_icon#twitter").hasClass("dim")).toBeTruthy();

      Publisher.bindServiceIcons();
      $(".service_icon#facebook").click();

      expect($(".service_icon#facebook").hasClass("dim")).toBeFalsy();
      expect($(".service_icon#twitter").hasClass("dim")).toBeTruthy();
    });

    it('binds to the services icons and toggles the hidden field', function(){
      spyOn(Publisher, 'toggleServiceField');
      Publisher.bindServiceIcons();
      $(".service_icon#facebook").click();

      expect(Publisher.toggleServiceField).toHaveBeenCalled();
    });
  });

  describe('toggleServiceField', function(){
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
    });

    it('adds a hidden field to the form if there is not one already', function(){
      expect($('#publisher [name="services[]"]').length).toBe(0);
      Publisher.toggleServiceField($(".service_icon#facebook").first());
      expect($('#publisher [name="services[]"]').length).toBe(1);
      expect($('#publisher [name="services[]"]').attr('value')).toBe("facebook");
    });

    it('removes the hidden field if its already there', function() {
      Publisher.toggleServiceField($(".service_icon#facebook").first());
      expect($('#publisher [name="services[]"]').length).toBe(1);

      Publisher.toggleServiceField($(".service_icon#facebook").first());
      expect($('#publisher [name="services[]"]').length).toBe(0);
    });

    it('does not remove a hidden field with a different value', function() {
      Publisher.toggleServiceField($(".service_icon#facebook").first());
      expect($('#publisher [name="services[]"]').length).toBe(1);

      Publisher.toggleServiceField($(".service_icon#twitter").first());
      expect($('#publisher [name="services[]"]').length).toBe(2);
    });
  });

  describe("input", function(){
    beforeEach(function(){
      spec.loadFixture('aspects_index_prefill');
    });
    it("returns the status_message_fake_text textarea", function(){
      expect(Publisher.input()[0].id).toBe('status_message_fake_text');
      expect(Publisher.input().length).toBe(1);
    });
  });
});
