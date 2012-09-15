        function gEBI(id) {
            return document.getElementById(id);
        }

        var savedSel = null;
        var savedSelActiveElement = null;

        function saveSelection(name) {
            // Remove markers for previously saved selection
           console.log("save");
            if (savedSel) {
                rangy.removeMarkers(savedSel);
            }
            savedSel = rangy.saveSelection();
            //savedSel = rangy.saveSelection(name);

            savedSelActiveElement = document.activeElement;
        }

        function restoreSelection() {
           console.log("restore");
            if (savedSel) {
                rangy.restoreSelection(savedSel, true);
                savedSel = null;
                window.setTimeout(function() {
                    if (savedSelActiveElement && typeof savedSelActiveElement.focus != "undefined") {
                        savedSelActiveElement.focus();
                    }
                }, 1);
            }
        }

        window.onload = function() {
            // Turn multiple selections on in IE
            try {
                document.execCommand("MultipleSelection", null, true);
            } catch(ex) {}

            rangy.init();

            // Enable buttons
            var saveRestoreModule = rangy.modules.SaveRestore;
            if (rangy.supported && saveRestoreModule && saveRestoreModule.supported) {
                // Display the control range element in IE
                if (rangy.features.implementsControlRange) {
                    gEBI("controlRange").style.display = "block";
                }
            }
        }
