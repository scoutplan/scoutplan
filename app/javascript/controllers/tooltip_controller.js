import { Controller } from "@hotwired/stimulus"
import { createPopper } from "@popperjs/core"

export default class extends Controller {
  connect() {
    window.process = { env: {} } // hack to make Popper work

    // iterate over trigger
    var triggerElements = this.queryTriggerElements(this.element);
    for(var i = 0; i < triggerElements.length; i++) {
      var triggerElem = triggerElements[i];
      this.setupTooltipTrigger(triggerElem);
    }
  }

  queryTriggerElements(parentNode) {
    return parentNode.querySelectorAll("[title]");
  }

  setupTooltipTrigger(triggerElem) {
    var tooltipElem = this.createTooltipElement(triggerElem);
    var popperInstance = this.createPopperInstance(triggerElem, tooltipElem);

    this.stripTitleAttribute(triggerElem);

    // attach both the tooltip element and the popper instance
    // directly to the trigger DOM object
    triggerElem.popperInstance = popperInstance;
    triggerElem.tooltipElem = tooltipElem;

    // set up the event listeners
    this.addTooltipMouseEnterListener(triggerElem);
    this.addTooltipMouseLeaveListener(triggerElem);    
  }

  stripTitleAttribute(elem) {
    elem.removeAttribute("title");
  }

  addTooltipMouseEnterListener(triggerElem) {
    triggerElem.addEventListener("mouseenter", function(event) {
      var tooltipElem = this.tooltipElem;
      var popperInstance = this.popperInstance;
      tooltipElem.classList.remove("hidden");
      popperInstance.update(); 
    });
  }

  addTooltipMouseLeaveListener(triggerElem) {
    triggerElem.addEventListener("mouseleave", function(event) {
      var tooltipElem = this.tooltipElem;
      tooltipElem.classList.add("hidden");
    });
  }

  createPopperInstance(triggerElem, tooltipElem) {
    var popperInstance = createPopper(triggerElem, tooltipElem, {
      placement: "top",
      strategy: "fixed",
      modifiers: [
        {
          name: 'offset',
          options: {
            offset: [0, 8],
          }
        },
        {
          name: 'eventListeners',
          enabled: false,
        },
      ],
    });
    return popperInstance;    
  }

  // create a new <div> tag to serve as the tooltip
  createTooltipElement(triggerElem) {
    var newTooltipElem = document.createElement("div");
    newTooltipElem.innerText = triggerElem.getAttribute("title");
    this.tooltipClasses().forEach(function(className) {
      newTooltipElem.classList.add(className);
    });
    triggerElem.parentNode.insertBefore(newTooltipElem, triggerElem);
    return newTooltipElem;
  }

  // tailwind classes to apply to the tooltip
  tooltipClasses() {
    return ["tooltip", "hidden", "rounded", "bg-black", "text-white", "px-4", "py-3", "max-w-xs", "block", "drop-shadow-md"];
  }
}