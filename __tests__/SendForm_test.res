open Jest
open Network
let mockFn = JestJs.fn(() => ())
open Expect
open RNTestingLibrary
module Router = ReactNavigation.Native.NavigationContainer
%%raw(`
jest.mock('@react-navigation/native', () => {
  return {
    useRoute: () => "bar",
    useNavigation:() => {}
  }
})
`)

describe("<SendScreen />", () => {
  let mockAccount = Account.make(
    ~tz1="foo"->Pkh.unsafeBuild,
    ~balance=30,
    ~pk="cool"->Pk.unsafeBuild,
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
    ~password as _,
    ~network as _,
    ~nodeIndex as _,
  ) => {
    let mockReponse = "mockHash"
    Promise.resolve(mockReponse)
  }

  let mockSimulate: SendAPI.simulate = (
    ~recipientTz1 as _,
    ~prettyAmount as _,
    ~assetType as _,
    ~senderTz1 as _,
    ~senderPk as _,
    ~network as _,
    ~nodeIndex as _,
  ) => {
    let mockResponse: Taquito.Toolkit.estimation = Obj.magic({
      "suggestedFeeMutez": 33,
    })
    Promise.resolve(mockResponse)
  }

  let screen = ref(RNTestingLibrary.render(<ReactNative.View />))

  test("it displays tez input by default", () => {
    let fixture =
      // <Router>
      <SendScreen.PureSendScreen
        sender=mockAccount
        nft=None
        notify={_ => ()}
        notifyAdvanced={_ => ()}
        navigate={_ => ()}
        network=Ghostnet
        nodeIndex=0
        send=mockSend
        simulate=mockSimulate
      />

    // </Router>
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
      <SendScreen.PureSendScreen
        sender=mockAccount
        nft=Some(nft)
        notify={_ => ()}
        notifyAdvanced={_ => ()}
        navigate={_ => ()}
        network=Ghostnet
        nodeIndex=0
        send=mockSend
        simulate=mockSimulate
      />
    screen.contents = RNTestingLibrary.render(fixture)
    let result = screen.contents->getByTestId(~matcher=#Str("nft-editions"))

    expect(result)->toHaveProp("value", "1")
  })
})
