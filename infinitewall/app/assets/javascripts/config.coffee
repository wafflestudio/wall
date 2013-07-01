requirejs.config
  baseUrl: '/assets/javascripts'
  paths: {
      jquery: 'jquery-2.0.2.min'
      "jquery-ui": 'jquery-ui.min'
      "jquery.ui.widget" : "jquery.ui.widget"
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
      "jquery.fileupload": ["jquery", "jquery.iframe-transport", "jquery.ui.widget"]
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
