document.querySelectorAll("input.switch").forEach(function(elem) {
  elem.addEventListener("change", function(event) {
    console.log(event);
    var wrapper = event.target.closest(".switch-wrapper");
    wrapper.classList.toggle("switch-on");
  });
});