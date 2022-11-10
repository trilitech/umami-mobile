module NameValidator = {
  let getError = str =>
    if str->Js.String2.length < 3 {
      #tooShort->Some
    } else if str->Js.String2.length > 20 {
      #tooLong->Some
    } else {
      None
    }

  let getErrorName = err => {
    switch err {
    | #tooShort => "Name is too short"
    | #tooLong => "Name is too long"
    }
  }
}
