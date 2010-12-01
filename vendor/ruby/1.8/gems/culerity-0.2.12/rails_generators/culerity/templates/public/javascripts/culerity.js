// this allows culerity to wait until all ajax requests have finished
jQuery(function($) {
	var original_ajax = $.ajax;
	var count_down = function(callback) {
		return function() {
			try {
				if(callback) {
					callback.apply(this, arguments);
				};
			} catch(e) {
				window.running_ajax_calls -= 1;
				throw(e);
			}
			window.running_ajax_calls -= 1;
		};
	};
	window.running_ajax_calls = 0;
	
	var ajax_with_count = function(options) {
		if(options.async == false) {
		  return(original_ajax(options));
		} else {
			window.running_ajax_calls += 1;
			options.success = count_down(options.success);
			options.error = count_down(options.error);
			return original_ajax(options);
		}
	};

	$.ajax = ajax_with_count;
});