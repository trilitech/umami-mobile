open Jest
let mockFn = JestJs.fn(() => ())
open Expect
open RNTestingLibrary
module Router = ReactNavigation.Native.NavigationContainer

describe("<RecordSecret />", () => {
  let mockAccount = Account.make(
    ~tz1="foo",
    ~balance=30,
    ~pk="cool",
    ~sk="mike",
    ~derivationPathIndex=0,
    (),
  )

  let mockSend: SendAPI.send = (
    ~prettyAmount as _,
    ~recipientTz1 as _,
    ~assetType as _,
    ~senderTz1 as _,
    ~sk as _,
    ~passphrase as _,
    ~isTestNet as _,
  ) => {
    let mockReponse: Taquito.Toolkit.operation = Obj.magic({"hash": "mockHash"})
    Promise.resolve(mockReponse)
  }

  let mockSimulate: SendAPI.simulate = (
    ~recipientTz1 as _,
    ~prettyAmount as _,
    ~assetType as _,
    ~senderTz1 as _,
    ~senderPk as _,
    ~isTestNet as _,
  ) => {
    let mockResponse: Taquito.Toolkit.estimation = Obj.magic({
      "suggestedFeeMutez": 33,
    })
    Promise.resolve(mockResponse)
  }

  let screen = ref(RNTestingLibrary.render(<ReactNative.View />))

  test("it displays tez input by default", () => {
    let fixture =
      <Router>
        <SendScreen.PureSendScreen
          sender=mockAccount
          nft=None
          tz1FromQr=None
          notify={_ => ()}
          notifyAdvanced={_ => ()}
          navigate={_ => ()}
          isTestNet=false
          send=mockSend
          simulate=mockSimulate
        />
      </Router>
    screen.contents = RNTestingLibrary.render(fixture)
    let result =
      screen.contents
      ->getByTestId(~matcher=#Str("text_input"))
      ->within
      ->getByTestId(~matcher=#Str("text_input"))

    expect(result)->toHaveProp("value", "tez")
  })

  test("it displays provided NFT with 1 copy by default", () => {
    let nft: Token.tokenNFT = (
      {id: 3, balance: 1, tz1: "foo", tokenId: "bar", contract: "foo"},
      {
        name: "cat",
        symbol: "bar",
        displayUri: "cool",
        thumbnailUri: "bar",
        description: "cool",
        creators: ["foo"],
      },
    )
    let fixture =
      <Router>
        <SendScreen.PureSendScreen
          sender=mockAccount
          nft=Some(nft)
          tz1FromQr=None
          notify={_ => ()}
          notifyAdvanced={_ => ()}
          navigate={_ => ()}
          isTestNet=false
          send=mockSend
          simulate=mockSimulate
        />
      </Router>
    screen.contents = RNTestingLibrary.render(fixture)
    let result = screen.contents->getByTestId(~matcher=#Str("nft-editions"))

    expect(result)->toHaveProp("value", "1")
  })
})
