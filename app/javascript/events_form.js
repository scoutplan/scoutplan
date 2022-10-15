function toggleActivityFields(show) {
  var fieldsElem = document.querySelector("#activity_name_field");
  fieldsElem.disabled = !show;
  if(show) {
    fieldsElem.focus();
  }
}

document.addEventListener("DOMContentLoaded", function() {
  document.querySelector("#event_requires_rsvp").addEventListener("click", function(event){
    var rsvpFields = document.querySelector("#rsvp_fields");
    rsvpFields.classList.toggle("hidden", !event.target.checked);
  });

  document.querySelector("#event_event_category_id").addEventListener("change", function(event) {
    var titleInput = document.querySelector("#event_title");
    if(titleInput.value != "") {
      return;
    }

    var sel = event.target;
    var text = sel.options[sel.selectedIndex].text;
    titleInput.value = text;
  });
});
