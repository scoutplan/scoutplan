import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const links = this.element.querySelectorAll("[data-sidebar-class]");
    links.forEach((link) => {

    });
  }

  setSidebarClass(className) {
    links.forEach((link) => {
      const linkClass = link.getAttribute("data-sidebar-class");
      body.classList.toggle(linkClass === className);
    });
  }
}