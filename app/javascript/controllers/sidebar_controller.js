import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  resizeObserver = null;

  connect() {
    this.resizeObserver = new ResizeObserver(() => {
      if (window.innerWidth < 768) {
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
}