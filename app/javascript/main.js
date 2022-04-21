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