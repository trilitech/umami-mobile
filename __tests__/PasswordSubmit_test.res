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

    let btn = screen.contents->getByText(~matcher=#Str("submit"))

    fireEvent->press(btn)
    ()
  })

  // testAsync("Manual submition", finish => {
  //   let fixture =
  //     <PasswordSubmit.Display
  //       bioMetricsEnabled=false
  //       onSubmit={p => {
  //         if p === mockPassword {
  //           finish(pass)
  //         }
  //       }}
  //     />
  //   let screen = ref(render(fixture))

  //   let input = screen.contents->getByTestId(~matcher=#Str("password"))

  //   fireEvent->changeText(input, ~input="manualPassword")
  // })
})
