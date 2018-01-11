$(document).on "click", ".reconcile-quantity", (e) ->
  e.preventDefault()
  $this = $(@)
  row = $this.parents("tr:first")
  return unless row.guard()

  $.ajax
    url: window.reconcileUrl
    method: "post"
    data:
      item_id: $this.data("item-id")
      new_amount: row.find(".reconcile-amount").val()
    success: ->
      row.removeClass("success danger").addClass("success")
      $this.removeClass("btn-success btn-danger").addClass("btn-success")
    error: ->
      row.removeClass("success danger").addClass("danger")
      $this.removeClass("btn-success btn-danger").addClass("btn-danger")
