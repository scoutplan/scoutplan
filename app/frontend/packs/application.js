// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// BOOTSTRAP see https://bootrails.com/blog/rails-bootstrap-tutorial and https://whatapalaver.co.uk/bootstrap-5-rails-6

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import "trix"
import "@rails/actiontext"

window.bootstrap = require('bootstrap/dist/js/bootstrap.bundle.js')

Rails.start()
Turbolinks.start()
ActiveStorage.start()
