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
});

// dropdown menu handlers
document.addEventListener("turbo:load", function() {
  // dropdown links open/close the menu
  document.querySelectorAll(".dropdown-button").forEach(function(linkElem) {
    linkElem.addEventListener("click", function(event) {
      event.target.closest(".dropdown").classList.toggle("menu-open");
      event.preventDefault();
      return false;
    });
  });

  // close a dropdown menu when one of its links is clicked
  document.querySelectorAll('.dropdown-menu a').forEach(function(linkElem) {
    linkElem.addEventListener('click', function(event) {
      document.querySelectorAll('.dropdown').forEach(function(elem) {
        elem.classList.remove(`menu-open`);
      })
    });
  });


  // close any open menus and dropdowns upon clicking anywhere on the page
  document.addEventListener('click', function(event) {
    var openMenus = document.querySelectorAll('.menu-open');
    if (openMenus.length == 0) {
      return;
    }
    openMenus.forEach(function(elem) {
      if (elem.contains(event.target)) {
        // clicked in the menu
      } else {
        elem.classList.remove('menu-open');
      }
    });
  });  
});