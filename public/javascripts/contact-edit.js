//   Copyright (c) 2011, Diaspora Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

(function(){
  var toggleCheckbox = function(checkbox){
    if(checkbox.attr('checked')){
      checkbox.removeAttr('checked');
    } else {
      checkbox.attr('checked', true);
    }
  };
  var processClick = function(li, evt){
    evt.preventDefault();

    var checkbox = li.find('input[type=checkbox]');
    toggleCheckbox(checkbox);

  };

  $(document).ready(function(){
    $('.dropdown .dropdown_list > li').live('click', function(evt){
      processClick($(this), evt);
    });
    $('.dropdown .dropdown_list > li *').live('click', function(evt){
      toggleCheckbox($(evt.target));
    })
  });
}())
