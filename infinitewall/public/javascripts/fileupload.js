$(function () {
    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload();

    // Load existing files:
    $('#fileupload').each(function () {
        var that = this;
        $.getJSON(this.action, function (result) {
            if (result && result.length) {
                $(that).fileupload('option', 'done')
                    .call(that, null, {result: result});
            }
        });
    });
});
