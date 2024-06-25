//= require guards

;(function($) {
    var originalDefaultTarget = $.guards.defaults.target;

    // Ensure input-group inputs have errors placed in the proper
    // location.
    $.guards.defaults.target = function(errorElement) {
        if (!$(this).parent().is(".input-group")) {
            return originalDefaultTarget.call(this, errorElement);
        }

        errorElement.insertAfter($(this).parent());
        return false;
    };

    // Make sure the error message class is the correct class.
    $.guards.defaults.messageClass = "help-block";

    // Add the error to the proper control group parent.
    $(document).on("afterGuardError", ":guardable", function(e) {
        $(e.errorElements).each(function() {
            if ($(this).is("[data-show-optional-icon]")) {
                var icon = $(this).data("show-optional-icon");

                if ($.guards.isBlank(icon)) {
                    icon = "remove";
                }

                $(this).parents(".form-group:first").addClass("has-feedback").append("<span class=\"glyphicon glyphicon-" + icon + " form-control-feedback\" data-generated-by-guards></span>");
            }

            $(this).parents(".form-group:first").addClass("has-error");
        });
    });

    $(document).on("afterClearGuardError", ":guardable", function(e) {
        $(e.errorElements).each(function() {
            if ($(this).is("[data-show-optional-icon]")) {
                $(this).parents(".form-group:first").removeClass("has-feedback").find("[data-generated-by-guards]").remove();
            }

            $(this).parents(".form-group:first").removeClass("has-error");
        });
    });
})(jQuery);
