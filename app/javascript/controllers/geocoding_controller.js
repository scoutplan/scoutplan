import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "placeName", "address", "activeInput" ];
  static values = {
    apiToken: String
  }

  initialize() {
    // this.map = new google.maps.Map();
    var elem = document.getElementById('main').appendChild(document.createElement('div'));
    this.placesService = new google.maps.places.PlacesService(elem);
  }
  
  connect() {
    this.createQueryResultElement();
    this.connectEventListeners();
  }

  disconnect() {
    console.log("Geocoding disconnect");
  }

  createQueryResultElement() {
    console.log("Geocoding connected.");
    this.resultsDiv = document.createElement("div");
    this.resultsDiv.setAttribute("id", "geocode_results")
    this.resultsDiv.classList.add("text-sm", "text-stone-500", "z-10", "w-24", "h-36", "shadow", "bg-white", "border", "border-stone-200", "rounded", "overflow-x-hidden", "overflow-y-auto", "absolute", "hidden");


    this.placeNameTarget.parentNode.appendChild(this.resultsDiv);

    var listElem = document.createElement("ul");
    this.resultsDiv.appendChild(listElem);
  }

  connectEventListeners() {
    var elem = document.querySelector("#geocode_results");
    document.addEventListener("click", function(event) {
      var resultsDiv = elem;
      resultsDiv.classList.add("hidden");
    });
    document.addEventListener("keyup", function(event) {
      if(event.key === "Escape") {
        var resultsDiv = elem;
        resultsDiv.classList.add("hidden");        
      }
    });
  }

  disconnectEventListeners() {
    document.removeEventListener("click");
    document.removeEventListener("keyup");
  }

  connectAutoComplete() {
    var options = {
      fields: ["name"],
      locationBias: true,
      types: ["establishment"],
    };
    this.autocomplete = new google.maps.places.Autocomplete(this.queryTarget, options);    
  }

  // TODO: modularize this mess
  performQuery(event) {
    this.activeInput = event.target;
    var searchTerm = event.target.value;
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
    this.positionQueryResultElement(event.target);

    // should we be using the Google Autocomplete API instead?
    this.placesService.findPlaceFromQuery(request, function(results, status) {
      if (status === google.maps.places.PlacesServiceStatus.OK) {
        resultsDiv.firstChild.innerHTML = "";
        for (var i = 0; i < results.length; i++) {
          var addressParts = results[i]["formatted_address"].split(",");
          var address = {
            country: addressParts.slice(-1)[0].trim(),
            state: addressParts.slice(-2)[0].trim().split(" ")[0],
            city: addressParts.slice(-3)[0].trim(), // TODO: this isn't right
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
      }
    });
  }

  // fired when user clicks on a query result
  select(event) {
    var elem = event.target;
    if (elem.nodeName != "A") { elem = elem.parentNode; }
    if (elem.nodeName != "A") {
      console.log("Something went wrong.");
      return;
    }

    if (this.activeInput == this.placeNameTarget) {
      this.placeNameTarget.value = elem.dataset.resultPlaceName;
      if (this.addressTarget.value == "") { this.addressTarget.value = elem.dataset.resultAddress; }
    } else if (this.activeInput == this.addressTarget) {
      this.addressTarget.value = elem.dataset.resultAddress;
      if (this.placeNameTarget.value == "") { this.placeNameTarget.value = elem.dataset.resultPlaceName; }
    }
    
    this.resultsDiv.classList.add("hidden");
    event.preventDefault(); // don't let the link click do anything
  }

  positionQueryResultElement(queryElem) {
    console.log(queryElem);
    this.resultsDiv.style.width = queryElem.clientWidth + 2 + "px";
    this.resultsDiv.style.left = queryElem.offsetLeft + "px";
    this.resultsDiv.style.top = queryElem.offsetTop + queryElem.clientHeight + 1 + "px";
  }
}
