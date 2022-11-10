open Jest

open RNTestingLibrary

let mockPassword = "mockPassword"
%%raw(`
jest.mock('@react-navigation/native', () => {
  return {
    useIsFocused:() => {}
  }
})
`)
module PasswordSubmit = PasswordSubmitBase.Make({
  let getKeychainPassword = () => Promise.resolve(mockPassword->Some)
})

let fixture = <PasswordSubmit.Display biometricsEnabled=true onSubmit={_ => {()}} />

let screen = ref(render(fixture))

describe("PasswordSubmit", () => {
  testAsync("Biometric submition", finish => {
    let fixture =
      <PasswordSubmit.Display
        biometricsEnabled=true
        onSubmit={p => {
          if p === mockPassword {
            finish(pass)
          }
        }}
      />
    let screen = ref(render(fixture))

    let btn = screen.contents->getByText(~matcher=#RegExp(%re("/submit/i")))

    fireEvent->press(btn)
    ()
  })

  testAsync("Manual submition", finish => {
    let manuapPassword = "manual"
    let fixture =
      <PasswordSubmit.Display
        label="submit"
        biometricsEnabled=false
        onSubmit={p => {
          if p === manuapPassword {
            finish(pass)
          }
        }}
      />
    let screen = ref(render(fixture))

    let input = screen.contents->getByTestId(~matcher=#RegExp(%re("/password/i")))
    fireEvent->changeText(input, ~input=manuapPassword)
    let submitBtn = screen.contents->getByText(~matcher=#RegExp(%re("/submit/i")))

    fireEvent->press(submitBtn)
  })
})
