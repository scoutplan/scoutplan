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

