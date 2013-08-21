/*!
 * jQuery Plugin: Are-You-Sure (Dirty Form Detection)
 * https://github.com/codedance/jquery.AreYouSure/
 *
 * Copyright (c) 2012-2013, Chris Dance and PaperCut Software http://www.papercut.com/
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 * Author:   chris.dance@papercut.com
 * Version:  1.3.1
 * Date:     24th July 2013
 */
(function($) {
  $.fn.areYouSure = function(options) {
    var settings = $.extend(
          {
            'message' : 'You have unsaved changes!',
            'dirtyClass' : 'dirty',
            'change' : null,
            'fieldSelector' : "select,textarea,input[type='text'],input[type='password'],input[type='checkbox'],input[type='radio'],input[type='hidden']"
          }, options);

    var getValue = function($field) {
      if ($field.hasClass('ays-ignore')
          || $field.hasClass('aysIgnore')
          || $field.attr('data-ays-ignore')
          || $field.attr('name') === undefined) {
        return null;
      }

      if ($field.is(':disabled')) {
        return 'ays-disabled';
      }

      var val;
      var type = $field.attr('type');
      if ($field.is('select')) {
        type = 'select';
      }

      switch (type) {
        case 'checkbox':
        case 'radio':
          val = $field.is(':checked');
          break;
        case 'select':
          val = '';
          $field.children('option').each(function(o) {
            var $option = $(this);
            if ($option.is(':selected')) {
              val += $option.val();
            }
          });
          break;
        default:
          val = $field.val();
      }

      return val;
    };

    var storeOrigValue = function() {
      var $field = $(this);
      $field.data('ays-orig', getValue($field));
    };

    var checkForm = function(evt) {
      var isFieldDirty = function($field) {
        return (getValue($field) != $field.data('ays-orig'));
      };

      var isDirty = false;
      var $form = $(this).parents('form');

      // Test on the target first as it's the most likely to be dirty.
      if (isFieldDirty($(evt.target))) {
        isDirty = true;
      }

      if (!isDirty) {
        $form.find(settings.fieldSelector).each(function() {
          $field = $(this);
          if (isFieldDirty($field)) {
            isDirty = true;
            return false; // break
          }
        });
      }

      markDirty($form, isDirty);
    };
    
    var markDirty = function($form, isDirty) {
      var changed = isDirty != $form.hasClass(settings.dirtyClass);
      $form.toggleClass(settings.dirtyClass, isDirty);

      // Fire change event if required
      if (changed && settings.change) {
        settings.change.call($form, $form);
      }
    };

    $(window).bind('beforeunload', function() {
      $dirtyForms = $("form").filter('.' + settings.dirtyClass);
      if ($dirtyForms.length > 0) {
        // $dirtyForms.removeClass(settings.dirtyClass); // Prevent multiple calls?
        return settings.message;
      }
    });

    return this.each(function(elem) {
      if (!$(this).is('form')) {
        return;
      }
      $(this).submit(function() {
        $(this).removeClass(settings.dirtyClass);
      });

      $(this).find(settings.fieldSelector).each(storeOrigValue);
      $(this).find(settings.fieldSelector).bind('change keyup', checkForm);
      $(this).bind('reset', function() { markDirty($(this), false); });
    });
  };
})(jQuery);
