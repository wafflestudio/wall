requirejs.config
  baseUrl: '/assets/javascripts'
  paths: {
      jquery: 'jquery-1.9.0.min'
      "jquery-ui": 'jquery-ui-1.8.23.custom.min'
      "jquery.ui.widget" : "jquery-ui-1.8.23.custom.min"
      underscore: "underscore-min"
      raphael: "raphael-min"
  },
  shim: {
      underscore: {
        exports: '_'
      }
      raphael: {
        exports: "Raphael"
      }
      bootstrap: ["jquery"]
      "jquery.transit": ["jquery"]
      "jquery.mousewheel": ["jquery"]
      "jquery.animate-shadow": ["jquery"]
      "jquery.proximity": ["jquery"]
      "jquery.ba-resize": ["jquery"]
      "jquery.iframe-transport": ["jquery"]
      "jquery.fileupload": ["jquery", "jquery.iframe-transport"]
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
  }
