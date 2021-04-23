/* Obtain consent from experiment participant. */
var check_consent = function(elem) {
	if ($('#consent_checkbox').is(':checked')) { return true; }
	else {
		alert("If you wish to participate, you must check the box.");
		return false;
	}
	return false;
};