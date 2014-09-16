$.validator.setDefaults
  highlight: (element) ->
    $(element).closest(".form-group").addClass("has-error")
  unhighlight: (element) ->
    $(element).closest(".form-group").removeClass("has-error")

  errorElement: "span"
  errorClass: "helo-block"

jQuery.validator.addMethod "format", ((value, element, param) ->
    @optional(element) or param.test(value)
), "Please fix this field."

