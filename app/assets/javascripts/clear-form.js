/* Clear form plugin - called using $("elem").clearForm(); */
$.fn.clearForm = function() {
  return this.each(function() {
    if ($(this).is('form')) {
      return $(':input', this).clearForm();
    }
    if ($(this).hasClass('clear_on_submit') || $(this).is(':text') || $(this).is(':password') || $(this).is('textarea')) {
      $(this).val('');
    } else if ($(this).is(':checkbox') || $(this).is(':radio')) {
      $(this).attr('checked', false);
    } else if ($(this).is('select')) {
      this.selectedIndex = -1;
    } else if ($(this).attr('name') == 'photos[]') {
      $(this).val('');
    }
    $(this).blur();
  });
};

