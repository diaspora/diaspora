$(document).ready(function(){
  /* profile page: aspect-dropdown */

  // renders the cover text for the dropdown
  function profileAspectDropdown_refresh($el) {
    var cover_text, num_selected = $el.find('option.selected').length;
    if(num_selected === 0) {
      $el.removeClass('has_connection');
      cover_text = Diaspora.I18n.t('aspect_dropdown.add_to_aspect');
    } else {
      $el.addClass('has_connection');
      if(num_selected === 1) {
        cover_text = $el.find('option.selected').data('name');
      } else {
        cover_text = Diaspora.I18n.t('aspect_dropdown.toggle', { 'count' : num_selected });
      }
    }
    $el.find('option.list_cover').text(cover_text);
  }

  // onchange handler for aspect dropdown instances
  var profileAspectDropDown_onchange = function() {
    var $el      = $(this),
        selected = $el.find('option:selected');
    $el.find('option.list_cover').text(Diaspora.I18n.t('aspect_dropdown.updating'));
    $el.val('list_cover'); // switch back to cover

    if(selected.hasClass('selected')) {
      // remove from aspect
      var membershipId = selected.data("membership_id");

      $.ajax({
        url: Routes.aspectMembership(membershipId),
        type: "DELETE",
        dataType: "json",
        headers: {
          "Accept": "application/json, text/javascript, */*; q=0.01"
        }
      }).done(function() {
        selected.text("– " + Diaspora.I18n.t('aspect_dropdown.mobile_row_unchecked', {name: selected.data('name')}));
        selected.removeClass('selected');
        profileAspectDropdown_refresh($el);
      }).fail(function() {
        alert(Diaspora.I18n.t('aspect_dropdown.error_remove'));
        profileAspectDropdown_refresh($el);
      });

    } else {
      // add to aspect
      var person_id = $el.data('person-id');

      $.ajax({
        url: Routes.aspectMemberships(),
        data: JSON.stringify({
          "person_id": person_id,
          "aspect_id": parseInt(selected.val(), 10)
        }),
        processData: false,
        type: 'POST',
        dataType: 'json',
        headers: {
          'Accept': "application/json, text/javascript, */*; q=0.01"
        },
        contentType: "application/json; charset=UTF-8"
      }).done(function(data) {
        selected.data('membership_id', data.id); // remember membership-id
        selected.text("✓ " + Diaspora.I18n.t('aspect_dropdown.mobile_row_checked', {name: selected.data('name')}));
        selected.addClass('selected');
        profileAspectDropdown_refresh($el);
      }).fail(function() {
        alert(Diaspora.I18n.t('aspect_dropdown.error'));
        profileAspectDropdown_refresh($el);
      });

    }
  };

  // initialize list_cover and register eventhandler for every user_aspect dropdown there is
  $('.user_aspects').each(function() {
    profileAspectDropdown_refresh($(this));
    $(this).change(profileAspectDropDown_onchange);
  });
});
