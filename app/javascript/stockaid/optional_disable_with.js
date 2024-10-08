$(document).on("click", "form :submit:not([data-disable-with])", function() {
    let $this = $(this);
    let buttonsToReEnable = $this.parents("form:first").find(":submit[data-disable-with]").not($this);

    setTimeout(function() {
        buttonsToReEnable.each(function() { $(this).prop("disabled", false) });
    }, 1000);
});
