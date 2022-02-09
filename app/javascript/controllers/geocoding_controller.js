import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "query" ];
  static values = {
    apiToken: String
  }

  initialize() {
    // this.map = new google.maps.Map();
    var elem = document.getElementById('main').appendChild(document.createElement('div'));
    this.placesService = new google.maps.places.PlacesService(elem);
  }
  
  connect() {
    this.connectBespokeElem();
  }

  connectBespokeElem() {
    this.createQueryResultElement();
  }

  connectAutoComplete() {
    var options = {
      fields: ["name"],
      locationBias: true,
      types: ["establishment"],
    };
    this.autocomplete = new google.maps.places.Autocomplete(this.queryTarget, options);    
  }

  performQuery(event) {
    var searchTerm = this.queryTarget.value;
    var request = {
      query: searchTerm,
      fields: ["name", "formatted_address"],
    };

    // add current location bias if user permits
    navigator.geolocation.getCurrentPosition(function(position) {
      request["locationBias"] = {
        lat: position.coords.latitude,
        lng: position.coords.longitude,
      }
    });    

    var resultsDiv = this.resultsDiv;
    resultsDiv.classList.remove("hidden");

    this.placesService.findPlaceFromQuery(request, function(results, status) {
      if (status === google.maps.places.PlacesServiceStatus.OK) {
        resultsDiv.firstChild.innerHTML = "";
        for (var i = 0; i < results.length; i++) {
          var addressParts = results[i]["formatted_address"].split(",");
          var address = {
            country: addressParts.slice(-1)[0].trim(),
            state: addressParts.slice(-2)[0].trim().split(" ")[0],
            city: addressParts.slice(-3)[0].trim(),
          }

          var listItemElem = document.createElement("li");
          listItemElem.classList.add("p-2");
          listItemElem.innerHTML = 
            `<a class="overflow-x-hidden w-full hover:text-brand-500"
              data-action="click->geocoding#select"
              data-result-index="${i}"
              data-result-place-name="${results[i]["name"]}"
              data-result-address="${results[i]["formatted_address"]}"
              href="#">
            <strong class="mr-2">${results[i]["name"]}</strong>
            ${address.city}, ${address.state}
            </a>`;
          resultsDiv.firstChild.appendChild(listItemElem);
        }
      } else {
        this.resultsDiv.classList.add("hidden");
      }
    });
  }

  select(event) {
    var elem = event.target;
    if (elem.nodeName != "A") { elem = elem.parentNode; }
    var placeName = elem.dataset.resultPlaceName;
    this.queryTarget.value = placeName;
    this.resultsDiv.classList.add("hidden");
    event.preventDefault(); // don't let the link click do anything
  }

  createQueryResultElement() {
    console.log("Geocoding connected.");
    this.resultsDiv = document.createElement("div");
    this.resultsDiv.classList.add("text-sm", "text-stone-500", "w-24", "h-36", "shadow", "bg-white", "border", "border-stone-200", "rounded", "overflow-x-hidden", "overflow-y-auto", "absolute", "hidden");
    this.resultsDiv.style.width = this.queryTarget.clientWidth + 2 + "px";
    this.resultsDiv.style.left = this.queryTarget.offsetLeft + "px";

    this.queryTarget.parentNode.appendChild(this.resultsDiv);

    var listElem = document.createElement("ul");
    this.resultsDiv.appendChild(listElem);
  }
}
