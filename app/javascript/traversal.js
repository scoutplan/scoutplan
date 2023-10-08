Element.prototype.prev = function(selector = null, wraparound = false) {
  const wraparoundFunctionName = wraparound ? "lastSibling" : null;
  return this.traverse("previous", selector, wraparoundFunctionName);
}

Element.prototype.next = function(selector = null, wraparound = false) {
  const wraparoundFunctionName = wraparound ? "firstSibling" : null;
  return this.traverse("next", selector, wraparoundFunctionName);
}

Element.prototype.firstSibling = function(selector = null) {
  const result = this.parentNode.firstChild;
  if (selector == null || result.matches(selector)) { return result; }
  return result.next(selector);
}

Element.prototype.lastSibling = function(selector = null) {
  const result = this.parentNode.lastChild;
  if (selector == null || result.matches(selector)) { return result; }
  return result.prev(selector);
}

Element.prototype.traverse = function(dir, selector = null, wraparoundFunctionName = null) {
  const methodName = dir + "ElementSibling";
  var result = this[methodName];
  while (result) {
    if (selector == null || result.matches(selector)) { return result; }
    result = result[methodName];
  }
  if (wraparoundFunctionName) { return this[wraparoundFunctionName](selector); }
}