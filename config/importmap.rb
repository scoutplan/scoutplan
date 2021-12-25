# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.0/lib/index.js"
pin "stimulus-sortable", to: "https://ga.jspm.io/npm:stimulus-sortable@3.1.0/dist/stimulus-sortable.es.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.6/src/index.js"
