// reader!
(function($){
    
    /** 
     * this is a flash utility to show growl notifications to the client
     * usage:
     * flash.error("omg");
     * flash.message("hi!");
     */
    var flash = (function() {
        return {
            error: function(message, header) {
                $.jGrowl(message, {
                    sticky: true,
                    header: header || "Error"
                });
            },
            message: function(message) {
                $.jGrowl(message);
            }
        };
    })();

    var addSub = (function() {
        function register() {
            getForm().submit(subscribe);
        }

        function getForm() {
            return $("#add-form");
        }

        function getUrl() {
            return $("#url").val();
        }

        function subscribe(ev) {
            ev.preventDefault();
            console.log("got url: %o", getUrl());
            var formEl = getForm();
            $.post(formEl.attr("action"), formEl.serialize(), handleResponse);
            /*$.post(formEl.attr("action"), formEl.serialize(), function(data) {
                handleResponse(data, formEl);
            });*/
        }

        function handleResponse(data) {
            try {
                if (data.error) {
                    return flash.error(data.error);
                } else if (data.id) {
                    flash.message("Added subscription. Refresh page until ui add is finished."); 
                    // TODO update ui adding new node
                }
            } catch (e) {}
        }

        register();
    })();

})(jQuery);

