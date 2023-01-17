open Jest
open RescriptHooksTestingLibrary.Testing

let useCounter = () => {
  let (count, setCount) = React.useState(_ => 0)

  let increment = () => setCount(x => x + 1)

  (count, increment)
}

let mockPeer: ReBeacon.peerInfo = {"id": "mockId"}->Obj.magic
let mockPeer2: ReBeacon.peerInfo = {"id": "mockId2"}->Obj.magic

let mockPermission: ReBeacon.permissionInfo = {"accountIdentifier": "mockId"}->Obj.magic
let mockPermission2: ReBeacon.permissionInfo = {"accountIdentifier": "mockId2"}->Obj.magic

let getPeers = JestJs.fn(() => Promise.resolve([mockPeer, mockPeer2]))->MockJs.fn
let getPermissions = JestJs.fn(() => Promise.resolve([mockPermission, mockPermission2]))->MockJs.fn

let clientAddPeer = JestJs.fn(_ => {Promise.resolve()})

describe("Beacon", () => {
  open Expect
  describe("PeerData type", () => {
    test("it builds from tezos or umami url", () => {
      let beaconCode = "gTSV5LvWyJq6LH6XaS8ZYxndZT5ByoQYowx3DFkvjmQ8XbWp87973JHFM7Mtqu4LpPpd9eXkWFBBSg5TfqA5btqagnoNLiDMZuQ4i13LcKS5V9yQpp1gpgbLPdtBC3kTatHeo6a4wBt2xLoUtGtRWPYpLifnFbHXfFxvKZBdoyraWtyBntUfkH3R2BPYFANLoqKXQ24FRBTgu4abkrZJpRdTtJFCb1itmqT4z1jzvS4yZm4gfb8cGP6FNuWydSmfNaQjDK9DoqU14ENyuJ88XZDGHc6HA23vrkRUAx2QaGCQgPgPEFTvgQa6dvocMcAyMDRsDmETQLRhCQrNyd1AvawWQaXRDMp1d6tJciwAtZPbpQqs575uGLDa8W8c85ujekF7LBr4Jg62iTzLS1bP7B4p6vsM6c3s96CY2LCrZY"
      let result = (
        PeerData.buildFromUri("umami://?type=tzip10&data=" ++ beaconCode),
        PeerData.buildFromUri("tezos://?type=tzip10&data=" ++ beaconCode),
        PeerData.buildFromUri("invalidumami://?type=tzip10&data=" ++ beaconCode),
      )

      expect(result)->toEqual((
        beaconCode->PeerData.unsafeBuild->Some,
        beaconCode->PeerData.unsafeBuild->Some,
        None,
      ))
    })
  })

  describe("useInit", () => {
    testAsync(
      "it creates client with Umami Mobile name and calls onDone when client is ready",
      finish => {
        let client = {
          "getPeers": getPeers,
          "getPermissions": getPermissions,
          "init": _ => Promise.resolve(),
          "connect": _ => Promise.resolve(),
        }->Obj.magic

        let makeClientMock = JestJs.fn(_ => client)
        let makeClient = makeClientMock->MockJs.fn

        renderHook(() =>
          BeaconHooks._useInit(
            ~onDone=_ => {
              let expected: ReBeacon.WalletClient.options = {name: "Umami mobile"}
              if [expected] == makeClientMock->MockJs.calls {
                finish(pass)
              }
            },
            ~makeClient,
            ~onBeaconRequest=_ => (),
            (),
          )
        , ())->ignore
      },
    )
  })

  describe("usePeers", () => {
    testAsync("it returns client peers", finish => {
      let client = {
        "getPeers": getPeers,
        "getPermissions": getPermissions,
      }->Obj.magic

      let hookResult = renderHook(() => BeaconHooks.usePeers(client, ()), ())

      let waitForNextUpdate: unit => Promise.t<unit> = Obj.magic(hookResult)["waitForNextUpdate"]

      waitForNextUpdate()
      ->Promise.thenResolve(() => {
        let (peers, _, _, _) = hookResult.result.current
        if peers == [mockPeer, mockPeer2] {
          finish(pass)
        }
      })
      ->ignore
    })

    testAsync("addPeer notifies failures", finish => {
      let client = {
        "getPeers": getPeers,
        "getPermissions": getPermissions,
      }->Obj.magic

      let handleError = JestJs.fn(_ => ())

      let hookResult = renderHook(
        () => BeaconHooks.usePeers(client, ~onError={err => MockJs.fn(handleError)(err)}, ()),
        (),
      )

      let waitForNextUpdate: unit => Promise.t<unit> = Obj.magic(hookResult)["waitForNextUpdate"]

      let (_, _, addPeer, _) = hookResult.result.current

      act(() => addPeer("invalid peer"->PeerData.unsafeBuild)->ignore)

      waitForNextUpdate()
      ->Promise.thenResolve(() =>
        if handleError->MockJs.calls == ["Failed to add peer. Reason: Non-base58 character"] {
          finish(pass)
        }
      )
      ->ignore
    })

    testAsync("addPeer refreshes state with peers and permissions produced by client", finish => {
      let clientGetPeers = JestJs.fn(() => Promise.resolve([]))

      let clientGetPermissions = JestJs.fn(() => {
        Promise.resolve([])
      })

      let client = {
        "addPeer": clientAddPeer->MockJs.fn,
        "getPeers": clientGetPeers->MockJs.fn,
        "getPermissions": clientGetPermissions->MockJs.fn,
      }->Obj.magic

      let hookResult = renderHook(() => BeaconHooks.usePeers(client, ()), ())

      let waitForNextUpdate: unit => Promise.t<unit> = Obj.magic(hookResult)["waitForNextUpdate"]

      let (_, _, addPeer, _) = hookResult.result.current

      let validPeerStr =
        "419hUvAwDHeqf6dAbrHa7bosGZCCd9r6DZVFfsnynGh1KE7ZLVB2gStbJrGgu1x1GhqbY7qXkDScB4fKGCChakgpQvGFVXYBRnM3jYkEB9FzehQvF1UgYEJ5qrwuwzDM2b6F1RkYvHQvfPww8Y52zkg9bmWRHg8SMkBmRL3nCXZuZzVew1pTEoUg6ULg9CZmGYemZWsjht9zSy6buZoGgv4wB8yHsWtJem5YRwvh1Rcb1bAmUVsJvnfgm748SPandFwsdvohuirrRMV8VZTqzEdVEufZ1LiG7fdDNN2M3CqTkaLbFaYH5yRHHvpdnJLojZdJetSTdTmJqB6D1zYcbSbGysUerW7tnBPCBjYLz8MfYfZG2mBD4FqnsCKzCPN2CSEfdKaGRkkviCgJxriMpKSsHRhPUNgfNYv25e5L5KMh"->PeerData.unsafeBuild

      let peerInfo: ReBeacon.peerInfo = {
        "id": "dd0cace3-4d99-daf8-9823-03185a83a15a",
        "type": "p2p-pairing-request",
        "name": "objkt.com",
        "version": "3",
        "publicKey": "66385b04fe60f87d889d5a5af0d61a70f25faf6eaa37f88be8462395cd01c19e",
        "relayServer": "beacon-node-1.diamond.papers.tech",
        "icon": "https://assets.objkt.media/file/assets-002/objkt/objkt-logo.png",
      }->Obj.magic

      act(() => {
        addPeer(validPeerStr)->ignore
        clientGetPeers->MockJs.mockImplementationOnce(_ => Promise.resolve([peerInfo]))->ignore
        clientGetPermissions
        ->MockJs.mockImplementation(_ => Promise.resolve([mockPermission]))
        ->ignore
      })

      waitForNextUpdate()
      ->Promise.thenResolve(() => {
        let (peers, _, _addPeer, permisionInfos) = hookResult.result.current
        let expected =
          clientAddPeer->MockJs.calls == [peerInfo] &&
          clientGetPermissions->MockJs.calls == [[], [], []]->Obj.magic &&
          peers == [peerInfo] &&
          permisionInfos == [mockPermission]
        if expected {
          finish(pass)
        }
      })
      ->ignore
    })
  })
})
