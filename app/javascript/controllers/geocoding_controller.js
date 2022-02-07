import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "query" ];
  static values = {
    mapboxToken: String
  }

  initialize() {
    console.log(this.mapboxTokenValue);
    this.mapboxClient = mapboxSdk({ accessToken: this.mapboxTokenValue });
  }
  
  connect() {
    this.createQueryResultElement();
  }

  performQuery(event) {
    console.log(event);
    var searchTerm = this.queryTarget.value;
    var config = { query: searchTerm };

    // attempt to get user location through the browser
    navigator.geolocation.getCurrentPosition(function(position) {
      config.proximity = [
        position.coords.longitude,
        position.coords.latitude,
      ];
    });

    this.mapboxClient.geocoding.forwardGeocode(config)
      .send()
      .then(function(response) {
        console.log(response.body);
      });
  }

  createQueryResultElement() {
    console.log("Geocoding connected!!!");
    // TODO: create a div element
    // TODO: use popper to position it
  }
}
