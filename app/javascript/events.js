/* scroll event list */
// document.querySelector('#event_table_container').addEventListener('wheel', function(event) {
//   var div = event.target;
//   console.log(div.scrollYOffset);
//   document.querySelector('#page_header').classList.add('border-b', div.offsetTop > 500);
// });

/* BULK PUBLISH */

// wire up the bulk Publish button

document.addEventListener("DOMContentLoaded", function() {
  document.querySelector('#bulk_publish_execute_button').addEventListener('click', function(event) {
    document.querySelector('#bulk_action_form').submit();
    event.preventDefault();
  });

  // wire up the check/uncheck all box
  document.querySelector('#select_all_events_checkbox').addEventListener('click', function(event) {
    const checked = this.checked;
    document.querySelectorAll('.bulk-publish-checkbox').forEach(function (elem) {
        elem.checked = checked && elem.offsetParent !== null;
    });
    validateBulkPublishState();
  });

  // wire up event row checkboxes
  document.querySelectorAll('.bulk-publish-checkbox').forEach(function(elem) {
    elem.addEventListener('click', function(event) {
      validateBulkPublishState();
    });
  });

  // wire up Cancel bulk publish button
  document.querySelector('#cancel_bulk_publish').addEventListener('click', function(event) {
    document.body.classList.toggle('showing-only-draft-events');
    document.body.classList.toggle('events-filtered');
    event.preventDefault();
  });


  // upon content load, perform a hide operation and stand up
  // an observer on the <body> element to watch for changes
  hideEmptyMonthHeaders();
  const mutationObserver = new MutationObserver(bodyMutated);
  mutationObserver.observe(document.body, { attributes: true });  

  var bulkPublishExecuteButton = document.querySelector('#bulk_publish_execute_button');
  var originalBulkPublishExecuteButtonCaption = bulkPublishExecuteButton.value;
});

function validateBulkPublishState() {
  // tally up checked count
  const checkedCount = document.querySelectorAll('.event-row .bulk-selection input:checked').length;

  // enable execute button
  bulkPublishExecuteButton.disabled = (checkedCount == 0);

  // update execute button caption
  bulkPublishExecuteButton.value = originalBulkPublishExecuteButtonCaption + (checkedCount == 0 ? '' : ' (' + checkedCount + ')');
}

/* SHOW/HIDE MONTH HEADERS */

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

function hideEmptyMonthHeaders() {
  // first, iterate over all month rows and hide them...
  document.querySelectorAll('.event-month-boundary').forEach(function(elem) {
    elem.style.display = 'none';
  });

  console.log('All month headers are now hidden');

  // ...then, iterate over all visible event rows, traverse backward until we
  // hit a month header, and reveal it. There's an inefficiency here in that
  // we're iterating on every visible event row, meaning we'll repeatedly
  // unhide the same month headers. TODO: traverse forward to next month header,
  // then traverse from there to the next visible event row
  document.querySelectorAll('.event-row').forEach(function(elem) {
    var compStyles = window.getComputedStyle(elem);
    var compDisplay = compStyles.getPropertyValue('display');
    if(compDisplay == 'none') {
      return; // nothing to see here...move on
    }

    const selector = '.event-month-boundary';
    var monthHeader = queryPreviousSiblingSelector(elem, selector);
    console.log('Unhiding ' + monthHeader.innerText);
    monthHeader.style.display = 'table-row';
  });    
}

// callback when <body> classes change so we can recalculate
// visible & hidden month headers
function bodyMutated(mutationsList, observer) {
  mutationsList.forEach(function(mutation) {
    console.log(mutation.attributeName);
    if (mutation.attributeName === 'class') {
      hideEmptyMonthHeaders();
    }
  });
}

// dropdown menu handlers
document.addEventListener("turbo:load", function() {

  // close a dropdown menu when one of its links is clicked
  document.querySelectorAll('.dropdown a').forEach(function(linkElem) {
    linkElem.addEventListener('click', function(event) {
      document.querySelectorAll('.dropdown').forEach(function(elem) {
        elem.classList.remove('menu-open');
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
})