// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// BOOTSTRAP see https://bootrails.com/blog/rails-bootstrap-tutorial and https://whatapalaver.co.uk/bootstrap-5-rails-6

// import Rails from '@rails/ujs'
// import Turbolinks from 'turbolinks'
import * as ActiveStorage from '@rails/activestorage'
import 'channels'
import 'trix'
import '@rails/actiontext'

// const mbxClient = require('@mapbox/mapbox-sdk');
// const mbxGeocoding = require('@mapbox/mapbox-sdk/services/geocoding');

// TODO: import bootstrap modules
// see https://stackoverflow.com/questions/66613941/cant-toggle-bootstrap-5-js-not-initialized-properly
// and https://stackoverflow.com/questions/67348468/bootstrap-5-webpack-plugins-are-not-fully-functional

// import * as bootstrap from 'bootstrap';
// import '../js/bootstrap_custom.js'
// window.bootstrap = require('bootstrap/dist/js/bootstrap.bundle.js')

// Rails.start()
// Turbolinks.start()
ActiveStorage.start()

import { Application } from "@hotwired/stimulus"
import Turbo from "@hotwired/turbo"
window.Stimulus = Application.start()
import Sortable from "./sortable_controller"
window.Stimulus.register("sortable", Sortable)

import EventController from "./event_controller"
window.Stimulus.register('event', EventController)