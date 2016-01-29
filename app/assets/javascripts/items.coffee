class Items
  constructor: ->
    @el = $(document)

  setCategoryModalValues: ->
    @el.on "click", "button[data-create-item]", (e) =>
      $element = $(e.target)
      $("#category").val $element.data("category")
      $("#addItem").find(".category-label").text $element.data("category-desc")
      @createSizesCheckboxes($element)

      $("#addItem").modal("show")

  createSizesCheckboxes: (element) ->
    unless element.data("category-sizes") == ''
      sizes = element.data("category-sizes").split ','
    if sizes
      $("#addItem").find("#sizes").append("<label for='size'>Size</label>")
      for size, index in sizes
        sizeCheckbox =
        """
        <div class='checkbox'>
          <label>
            <input name="item[sizes][#{size}]" type="checkbox" id="size-#{size}" /> #{size}
          </label>
        </div>
        """
        $("#addItem").find("#sizes").append(sizeCheckbox)

  focusOnItemDescription: ->
    @el.on "shown.bs.modal", "#addItem", ->
      $("#description").focus()

  focusOnCategoryDescription: ->
    @el.on "shown.bs.modal", "#addCategory", ->
      $("[name='category[description]']").focus()

  clearSizesOnModalClose: ->
    @el.on "hidden.bs.modal", "#addItem", ->
      console.log $("#addItem").find("#sizes")
      $("#addItem").find("#sizes").html('')

items = new Items
items.setCategoryModalValues()
items.focusOnItemDescription()
items.focusOnCategoryDescription()
items.clearSizesOnModalClose()


