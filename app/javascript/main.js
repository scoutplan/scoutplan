// find the first prior sibling matching a given selector
function queryPreviousSiblingSelector(elem, selector) {
  var currentElem = elem;
  var done = false;
  while(!done) {
    currentElem = currentElem.previousSibling;
    if (currentElem === null) {
      return null;
    }
    done = currentElem.matches(selector);
  }

  return currentElem;
}

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll("main").forEach(function(elem) {
    elem.addEventListener("scroll", function(event) {
      console.log(event.target.scrollTop);
    });
  });
});

window.addEventListener("scroll", () => {
  document.body.classList.toggle("scrolled", window.scrollY > 0);
})