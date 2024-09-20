import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = [ "firstName", "lastName", "childRelationships", "parentRelationships" ];

  connect() {

  }

  changeRelationship(event) {
    const elem = event.target;
    const memberId = elem.dataset.memberId;
    const relatedMemberId = elem.value;
    const relationshipType = elem.dataset.relationshipType;

    if (elem.checked) {
      let url = `/relationship_candidates`;
      let formData = new FormData();
  
      formData.append("related_member_id", relatedMemberId);
      formData.append("relationship_type", relationshipType);
      post(url, { body: formData, responseKind: "turbo-stream" });
    } else {
      // find the relationship tag and delete it
      // let tagElem = document.querySelector(`[data-related-member-id="${relatedMemberId}"][data-relationship-type="${relationshipType}"]`);
      let selector = `#${relationshipType}_relationship_tag_${relatedMemberId}`;
      let tagElem = document.querySelector(selector);
      tagElem?.remove();
    }
  }
}