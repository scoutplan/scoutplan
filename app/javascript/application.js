// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"
import "@fortawesome/fontawesome"
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import * as ActionCable from "@rails/actioncable"
ActionCable.logger.enabled = true
import "./channels"

FontAwesome.config.mutateApproach = 'sync'