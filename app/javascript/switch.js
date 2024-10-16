document.querySelectorAll(".dp-switch").forEach(function(elem) {
  elem.addEventListener("change", function(event) {
    var wrapper = event.target.closest(".switch-toggle-container");
    wrapper.classList.toggle("switch-on");
  });
});