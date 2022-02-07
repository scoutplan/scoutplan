// import { Controller } from "@hotwired/stimulus"
// import { MapboxClient } from "@mapbox/mapbox-sdk"

// export default class extends Controller {
//   static targets = [ "query" ];

//   initialize() {
//     this.geocodingService = mbxGeocoding({ accessToken: this.mapboxToken });
//   }

//   connect() {
//     console.log("Geocoding connected!!!");
//     this.createQueryResultElement();
//   }

//   performQuery(event) {
//     console.log(event);
//     var searchTerm = this.queryTarget.value;
//     var config = { query: searchTerm };

//     // attempt to get user location through the browser
//     navigator.geolocation.getCurrentPosition(function(position) {
//       config.proximity = [
//         position.coords.longitude,
//         position.coords.latitude,
//       ];
//     });

//     console.log(config);

//     this.geocodingService.forwardGeocode(config)
//       .send()
//       .then(function(response) {
//         console.log(response.body);
//       });
//   }

//   createQueryResultElement() {
//     console.log("Geocoding connected!!!");
//     // TODO: create a div element
//     // TODO: use popper to position it
//   }
// }
