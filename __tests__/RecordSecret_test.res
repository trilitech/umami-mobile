open Jest
open RNTestingLibrary
let mockFn = JestJs.fn(() => ())
%%raw(`
jest.mock('@react-navigation/native', () => {
  return {
    useIsFocused: () => true,
    useRoute: () => "bar"
  }
})
`)

describe("<RecordSecret />", () => {
  open Expect

  let mnemonic = [
    "energy",
    "stay",
    "portion",
    "effort",
    "amazing",
    "travel",
    "boy",
    "film",
    "border",
    "coffee",
    "clean",
    "dance",
    "market",
    "leg",
    "spring",
    "obtain",
    "oblige",
    "cage",
    "crazy",
    "vacant",
    "impact",
    "slush",
    "humor",
    "trade",
  ]

  let fixture =
    <RecordSecretScreen.PureRecordSecret
      mnemonic
      onFinished={() => {
        mockFn->MockJs.fn()
      }}
    />
  let screen = ref(render(fixture))

  beforeEach(() => {
    screen.contents = render(fixture)
  })
  test("it displays 5 mnemonic words", () => {
    let res = screen.contents->getAllByTestId(~matcher=#Str("mnemonic-word"))

    expect(res->Belt.Array.length)->toEqual(5)
  })

  test("Yolo button bypasses questions", () => {
    let btn = screen.contents->getByText(~matcher=#RegExp(%re("/yolo/i")))
    fireEvent->press(btn)

    let calls = mockFn->MockJs.calls
    expect(calls)->toEqual([()])
  })
})
