/* scroll event list */
// document.querySelector('#event_table_container').addEventListener('wheel', function(event) {
//   var div = event.target;
//   console.log(div.scrollYOffset);
//   document.querySelector('#page_header').classList.add('border-b', div.offsetTop > 500);
// });

// determine which months contain events and which don't. Only show those that do.
function hideEmptyMonthHeaders() {
  // first, iterate over all month rows and hide them...
  document.querySelectorAll('.event-month-boundary').forEach(function(elem) {
    elem.style.display = 'none';
  });

  // ...then, iterate over all visible event rows, traverse backward until we
  // hit a month header, and reveal it. There's an inefficiency here in that
  // we're iterating on every visible event row, meaning we'll repeatedly
  // unhide the same month headers.
  // TODO: traverse forward to next month header, then traverse from there to the next visible event row
  document.querySelectorAll('.event-row').forEach(function(elem) {
    var compStyles = window.getComputedStyle(elem);
    var compDisplay = compStyles.getPropertyValue('display');
    if(compDisplay == 'none') {
      return; // nothing to see here...move on
    }

    const selector = '.event-month-boundary';
    var monthHeader = queryPreviousSiblingSelector(elem, selector);
    monthHeader.style.display = 'table-row';
  });    
}

document.addEventListener("DOMContentLoaded", function() {
  // START BULK PUBLISH

  // wire up the bulk Publish button
  document.querySelector('#bulk_publish_execute_button')?.addEventListener('click', function(event) {
    document.querySelector('#bulk_action_form').submit();
    event.preventDefault();
  });

  // wire up the check/uncheck all box
  // document.querySelector('#select_all_events_checkbox')?.addEventListener('click', function(event) {
  //   const checked = this.checked;
  //   document.querySelectorAll('.bulk-publish-checkbox').forEach(function (elem) {
  //       elem.checked = checked && elem.offsetParent !== null;
  //   });
  //   validateBulkPublishState();
  // });

  document.querySelector("#check_all_button")?.addEventListener("click", function(event) {
    selectAllBulkPublish(true);
    event.preventDefault();
  });

  document.querySelector("#uncheck_all_button")?.addEventListener("click", function(event) {
    selectAllBulkPublish(false);
    event.preventDefault();
  });  

  // wire up event row checkboxes
  document.querySelectorAll("input.bulk-publish-checkbox").forEach(function(elem) {
    elem.addEventListener("click", function(event) {
      validateBulkPublishState();
    });
  });

  // wire up Cancel bulk publish button
  document.querySelector('#cancel_bulk_publish')?.addEventListener('click', function(event) {
    document.body.classList.toggle('showing-only-draft-events');
    document.body.classList.toggle('events-filtered');
    event.preventDefault();
  });

  // END BULK PUBLISH  

  // As the user changes visibility options (e.g. show/hide cancelled), we need to
  // recalculate which month headers should be shown or hidden. Months containing
  // zero visible events should be hidden, whereas months containing events should be
  // shown. To accomplish this, we establish a mutation observer on the <body> element,
  // looking for changes to the body CSS classes. Those class changes correspond to
  // visibliity changes
  const mutationObserver = new MutationObserver(bodyMutated);
  mutationObserver.observe(document.body, { attributes: true });  

  // ...and then run the show/hide algorithm once to kick us off
  // hideEmptyMonthHeaders();
}); // end DOMContentLoaded

var gOriginalBulkPublishExecuteButtonCaption;

// fired whenever a bulk update checkbox is clicked
function validateBulkPublishState() {
  // tally up checked count
  const checkedCount = document.querySelectorAll("input.bulk-publish-checkbox:checked").length;

  // enable execute button
  var bulkPublishExecuteButton = document.querySelector("#bulk_publish_execute_button");
  bulkPublishExecuteButton.disabled = (checkedCount == 0);

  // store the original caption, if needed
  gOriginalBulkPublishExecuteButtonCaption = gOriginalBulkPublishExecuteButtonCaption ?? bulkPublishExecuteButton?.value;

  // update execute button caption
  bulkPublishExecuteButton.value = gOriginalBulkPublishExecuteButtonCaption + (checkedCount == 0 ? '' : ' (' + checkedCount + ')');
}

function selectAllBulkPublish(checked) {
  document.querySelectorAll(".event-draft:not(.event-past) .bulk-publish-checkbox").forEach(function(elem) {
    elem.checked = checked;
  });
  validateBulkPublishState();
}

/* SHOW/HIDE MONTH HEADERS */

// // find the first prior sibling matching a given selector
// function queryPreviousSiblingSelector(elem, selector) {
//   var currentElem = elem;
//   var done = false;
//   while(!done) {
//     currentElem = currentElem.previousSibling;
//     if (currentElem === null) {
//       return null;
//     }
//     done = currentElem.matches(selector);
//   }

//   return currentElem;
// }

// callback when <body> classes change so we can recalculate
// visible & hidden month headers
function bodyMutated(mutationsList, observer) {
  mutationsList.forEach(function(mutation) {
    if (mutation.attributeName === 'class') {
      // hideEmptyMonthHeaders();
    }
  });
}