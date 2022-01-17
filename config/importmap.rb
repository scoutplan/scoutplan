# Pin npm packages by running ./bin/importmap pin <libraryname>

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.0/lib/index.js"
pin "stimulus-sortable", to: "https://ga.jspm.io/npm:stimulus-sortable@3.1.0/dist/stimulus-sortable.es.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.6/src/index.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix", to: "https://ga.jspm.io/npm:trix@1.3.1/dist/trix.js"
pin "process", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.14/nodelibs/browser/process-production.js"
pin "@rails/actiontext", to: "https://ga.jspm.io/npm:@rails/actiontext@7.0.1/app/javascript/actiontext/index.js"
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@7.0.1/app/assets/javascripts/activestorage.esm.js"
