import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log("ProfileFormController#connect");
  }

  changeCommsSettings(event) {

  }

  switchProfile(event) {
    const memberId = event.target.value;
    const url = `/profiles/${memberId}/edit`;
    window.location = url;
  }


}