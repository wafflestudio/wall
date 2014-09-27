requirejs.config
  #baseUrl: '/assets/javascripts-min/'
  paths: {
      jquery: 'jquery-2.0.2.min'
      "jquery-ui": 'jquery-ui.min'
      "jquery.ui.widget" : "jquery.ui.widget"
      underscore: "underscore-min"
      raphael: "raphael-min"
      "jquery.fileupload": "fileupload/jquery.fileupload"
      #"jquery.fileupload-process": "fileupload/jquery.fileupload-process"
      #"jquery.fileupload-image": "fileupload/jquery.fileupload-image"
      "load-image": "fileupload/load-image"
      #"load-image-meta": "fileupload/load-image-meta"
      #"load-image-exif": "fileupload/load-image-exif"
      #"load-image-ios": "fileupload/load-image-ios"
      "canvas-to-blob": "fileupload/canvas-to-blob"
      angular: "webjars!angular"
      "angular-route": "webjars!angular-route"
      "underscorejs": "webjars!underscorejs"
  },
  shim: {
      hallo : {
        deps: ["jquery","jquery.ui.widget", "rangy-core"]
        exports: "jQuery.fn.hallo"
      }
      underscore: {
        exports: '_'
      }
      raphael: {
        exports: "Raphael"
      }
      bootstrap: ["jquery"]
      "tree.jquery" : ["jquery"]
      "jquery.transit": ["jquery"]
      "jquery.mousewheel": ["jquery"]
      "jquery.animate-shadow": ["jquery"]
      "jquery.proximity": ["jquery"]
      "jquery.ba-resize": ["jquery"]
      "jquery.fileupload": [
        "jquery",
        "jquery.ui.widget",
        "canvas-to-blob",
        "load-image",
        #"jquery.iframe-transport",
        #"jquery.fileupload-process"
        #"jquery.fileupload-image"
      ]
      "rangy-core" : {
        exports: "rangy"
        init: () ->
          @rangy
      }
      'rangy/rangy-selectionsaverestore': {
        deps: ["rangy-core"],
        exports: "rangy.modules.SaveRestore"
      }
      #"rangy-textrange" : ["rangy-core"]
      #"rangy-cssclassapplier" : ["rangy-core"]
      "rangy-selectionsaverestore" : ["rangy-core"]
      angular: {
        exports: "angular"
        deps: ["jquery"]
      }
      "angular-route": {
        deps: ["angular"]
      }
      "ui-bootstrap":{
        deps: ["angular", "bootstrap"]
      }
  }
