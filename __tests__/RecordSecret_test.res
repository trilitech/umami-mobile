open Jest
open RNTestingLibrary
let mockFn = JestJs.fn(() => ())

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
    <RecordSecret.PureRecordSecret
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

  test("it displays next button", () => {
    let btn = screen.contents->getByText(~matcher=#RegExp(%re("/next/i")))
    fireEvent->press(btn)
    fireEvent->press(btn)
    fireEvent->press(btn)

    let calls = mockFn->MockJs.calls
    expect(calls)->toEqual([()])
  })
})
