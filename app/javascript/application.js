// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"
import "@mapbox/mapbox-sdk"

import * as ActionCable from "@rails/actioncable"
ActionCable.logger.enabled = true
