import { Controller } from "@hotwired/stimulus"
import { createPopper } from "@popperjs/core"

export default class extends Controller {
  // static targets = [ "source" ];

  connect() {
    console.log("Tooltip controller loaded");
    window.process = { env: {} }
    const controller = this;
    var triggerElements = this.element.querySelectorAll("[title]");
    triggerElements.forEach(function(triggerElem) {
      var tooltipElem = controller.createTooltipElement(triggerElem);
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
      triggerElem.popperInstance = popperInstance;
      triggerElem.tooltipElem = tooltipElem;

      triggerElem.addEventListener("mouseenter", function(event) {
        var tooltipElem = this.tooltipElem;
        var popperInstance = this.popperInstance;
        tooltipElem.classList.remove("hidden");
        popperInstance.update();
      });

      triggerElem.addEventListener("mouseleave", function() {
        var tooltipElem = this.tooltipElem;
        tooltipElem.classList.add("hidden");
      });
    });
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
    return ["tooltip", "hidden", "rounded", "bg-black", "text-white", "px-4", "py-3", "max-w-xs", "block"];
  }
}