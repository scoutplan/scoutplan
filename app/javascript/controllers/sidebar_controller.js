import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  resizeObserver = null;
  AUTO_TOGGLE_WIDTH = 1000;

  connect() {
    this.resizeObserver = new ResizeObserver(() => {
      if (window.innerWidth < this.AUTO_TOGGLE_WIDTH) {
        document.body.classList.remove("sidebar-open");
      } else {
        document.body.classList.add("sidebar-open");
      }
    });

    this.resizeObserver.observe(window.document.body);
  }

  setSidebarClass(className) {
    links.forEach((link) => {
      const linkClass = link.getAttribute("data-sidebar-class");
      body.classList.toggle(linkClass === className);
    });
  }

  toggle(event) {
    document.body.classList.toggle("sidebar-open");
  }

  activate(event) {
    const links = this.element.querySelectorAll("[data-sidebar-class]");
    links.forEach((link) => {
      const className = link.getAttribute("data-sidebar-class");
      document.body.classList.remove(className);
    });
    
    const className = event.target.dataset.sidebarClass;
    document.body.classList.add(className);
    // console.log(event.target);
  }
}