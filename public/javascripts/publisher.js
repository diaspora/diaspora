/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//TODO: make this a widget
var Publisher = {
  close: function(){
    Publisher.form().addClass('closed');
    Publisher.form().find(".options_and_submit").hide();
         },
  open: function(){
    Publisher.form().removeClass('closed');
    Publisher.form().find(".options_and_submit").show();
  },
  cachedForm : false,
  form: function(){
    if(!Publisher.cachedForm){
      Publisher.cachedForm = $('#publisher');
    }
    return Publisher.cachedForm;
  },
  cachedInput : false,
  input: function(){
    if(!Publisher.cachedInput){
      Publisher.cachedInput = Publisher.form().find('#status_message_fake_message');
    }
    return Publisher.cachedInput;
  },

  updateHiddenField: function(evt){
   Publisher.form().find('#status_message_message').val(
    Publisher.input().val());
  },
  autocompletion: {
    options : function(){return {
      minChars : 1,
      max : 5,
      searchTermFromValue: Publisher.autocompletion.searchTermFromValue,
      scroll : false,
      formatItem: function(row, i, max) {
          return row.name;
      },
      formatMatch: function(row, i, max) {
          return row.name;
      },
      formatResult: function(row) {
          return row.name;
      }
    };},

    selectItemCallback :  function(event, data, formatted) {
      var textarea = Publisher.input();
      textarea.val(formatted);
    },

    searchTermFromValue: function(value, cursorIndex)
    {
      var atLocation = value.lastIndexOf('@', cursorIndex);
      if(atLocation == -1){return '';}
      var nextAt = value.indexOf('@', cursorIndex+1);

      if(nextAt == -1){nextAt = value.length;}
      if(atLocation < 2){
        atLocation = 0;
      }else{ atLocation = atLocation -2 }

      relevantString = value.slice(atLocation, nextAt).replace(/\s+$/,"");
      matches = relevantString.match(/(^|\s)@(.+)/);
      if(matches){
        return matches[2];
      }else{
        return '';
      }
    },
    contactsJSON: function(){
      return $.parseJSON($('#contact_json').val());
    },
    initialize: function(){
      Publisher.input().autocomplete(Publisher.autocompletion.contactsJSON(),
        Publisher.autocompletion.options());
      Publisher.input().result(Publisher.autocompletion.selectItemCallback);
    }
  },
  initialize: function() {
    Publisher.cachedForm = false;
    Publisher.cachedInput = false;
    $("div.public_toggle input").live("click", function(evt) {
      $("#publisher_service_icons").toggleClass("dim");
      if ($(this).attr('checked') == true) {
        $(".question_mark").click();
      }
    });

    if ($("#status_message_fake_message").val() == "") {
      Publisher.close();
    };

    Publisher.autocompletion.initialize();
    Publisher.updateHiddenField();
    Publisher.form().find('#status_message_fake_message').change(
        Publisher.updateHiddenField);
    Publisher.form().find("textarea").bind("focus", function(evt) {
      Publisher.open();
      $(this).css('min-height', '42px');
    });
  }
};

$(document).ready(function() {
  Publisher.initialize();
});
