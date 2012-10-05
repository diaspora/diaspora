//= require scrypto-config
//= require scrypto/scrypto

$(document).ready(function() {
	if ($('#entropy-value').length > 0) {
		$(document).entropy(function(progress) {
			$('#entropy-value').text((progress * 100).toFixed(0) + "%")
		})
	}
})
