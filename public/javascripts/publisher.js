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

  cachedHiddenInput : false,
  hiddenInput: function(){
    if(!Publisher.cachedHiddenInput){
      Publisher.cachedHiddenInput = Publisher.form().find('#status_message_message');
    }
    return Publisher.cachedHiddenInput;
  },

  appendToHiddenField: function(evt){
   Publisher.hiddenInput().val(
    Publisher.input().val());
  },

  autocompletion: {
    options : function(){return {
      minChars : 1,
      max : 5,
      onSelect : Publisher.autocompletion.onSelect,
      searchTermFromValue: Publisher.autocompletion.searchTermFromValue,
      scroll : false,
      formatItem: function(row, i, max) {
          return "<img src='"+ row.avatar +"' class='avatar'/>" + row.name;
      },
      formatMatch: function(row, i, max) {
          return row.name;
      },
      formatResult: function(row) {
          return row.name;
      }
    };},

    onSelect :  function(input, data, formatted) {
      addMentionToVisibleInput(input, formatted);
    },

    addMentionToVisibleInput: function(input, formatted){
      var cursorIndex = input[0].selectionStart;
      var inputContent = input.val();

      var stringLoc = Publisher.autocompletion.findStringToReplace(input.val(), cursorIndex);

      var stringStart = inputContent.slice(0, stringLoc[0]);
      var stringEnd = inputContent.slice(stringLoc[1]);

      input.val(stringStart + formatted + stringEnd);
    },

    findStringToReplace: function(value, cursorIndex){
      var atLocation = value.lastIndexOf('@', cursorIndex);
      if(atLocation == -1){return [0,0];}
      var nextAt = value.indexOf('@', cursorIndex+1);

      if(nextAt == -1){nextAt = value.length;}
      return [atLocation, nextAt];

    },

    searchTermFromValue: function(value, cursorIndex)
    {
      var stringLoc = Publisher.autocompletion.findStringToReplace(value, cursorIndex);
      if(stringLoc[0] <= 2){
        stringLoc[0] = 0;
      }else{
        stringLoc[0] -= 2
      }

      var relevantString = value.slice(stringLoc[0], stringLoc[1]).replace(/\s+$/,"");

      var matches = relevantString.match(/(^|\s)@(.+)/);
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
    Publisher.form().find('#status_message_fake_message').bind('keydown',
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
