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

describe("Beacon", () => {
  describe("peer hooks", () => {
    testAsync("it returns client peers", finish => {
      let client = {
        "getPeers": getPeers,
        "getPermissions": getPermissions,
      }->Obj.magic

      let hookResult = renderHook(() => Beacon.usePeers(client, ()), ())

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
        () => Beacon.usePeers(client, ~onError={err => MockJs.fn(handleError)(err)}, ()),
        (),
      )

      let waitForNextUpdate: unit => Promise.t<unit> = Obj.magic(hookResult)["waitForNextUpdate"]

      let (_, _, addPeer, _) = hookResult.result.current

      act(() => addPeer("invalid peer")->ignore)

      waitForNextUpdate()
      ->Promise.thenResolve(() =>
        if handleError->MockJs.calls == ["Failed to add peer. Reason: Non-base58 character"] {
          finish(pass)
        }
      )
      ->ignore
    })

    testAsync("addPeer refreshes state with peers and permissions produced by client", finish => {
      let clientAddPeer = JestJs.fn(_ => {Promise.resolve()})
      let clientGetPeers = JestJs.fn(() => Promise.resolve([]))

      let clientGetPermissions = JestJs.fn(() => {
        Promise.resolve([])
      })

      let client = {
        "addPeer": clientAddPeer->MockJs.fn,
        "getPeers": clientGetPeers->MockJs.fn,
        "getPermissions": clientGetPermissions->MockJs.fn,
      }->Obj.magic

      let hookResult = renderHook(() => Beacon.usePeers(client, ()), ())

      let waitForNextUpdate: unit => Promise.t<unit> = Obj.magic(hookResult)["waitForNextUpdate"]

      let (_, _, addPeer, _) = hookResult.result.current

      let validPeerStr = "419hUvAwDHeqf6dAbrHa7bosGZCCd9r6DZVFfsnynGh1KE7ZLVB2gStbJrGgu1x1GhqbY7qXkDScB4fKGCChakgpQvGFVXYBRnM3jYkEB9FzehQvF1UgYEJ5qrwuwzDM2b6F1RkYvHQvfPww8Y52zkg9bmWRHg8SMkBmRL3nCXZuZzVew1pTEoUg6ULg9CZmGYemZWsjht9zSy6buZoGgv4wB8yHsWtJem5YRwvh1Rcb1bAmUVsJvnfgm748SPandFwsdvohuirrRMV8VZTqzEdVEufZ1LiG7fdDNN2M3CqTkaLbFaYH5yRHHvpdnJLojZdJetSTdTmJqB6D1zYcbSbGysUerW7tnBPCBjYLz8MfYfZG2mBD4FqnsCKzCPN2CSEfdKaGRkkviCgJxriMpKSsHRhPUNgfNYv25e5L5KMh"

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

    testAsync("addPeer replaces existing peer if it has same name", finish => {
      let clientAddPeer = JestJs.fn(_ => {Promise.resolve()})
      let clientRemovePeer = JestJs.fn(_ => {
        Promise.resolve()
      })
      let clientGetPeers = JestJs.fn(() => Promise.resolve([]))

      let getPermissions = JestJs.fn(() => Promise.resolve([]))

      let client = {
        "addPeer": clientAddPeer->MockJs.fn,
        "removePeer": clientRemovePeer->MockJs.fn,
        "getPeers": clientGetPeers->MockJs.fn,
        "getPermissions": getPermissions->MockJs.fn,
      }->Obj.magic

      let handleError = JestJs.fn(_ => ())

      let hookResult = renderHook(
        () => Beacon.usePeers(client, ~onError={err => MockJs.fn(handleError)(err)}, ()),
        (),
      )

      let waitForNextUpdate: unit => Promise.t<unit> = Obj.magic(hookResult)["waitForNextUpdate"]

      let (_, _, addPeer, _) = hookResult.result.current

      let validPeerStr = "419hUvAwDHeqf6dAbrHa7bosGZCCd9r6DZVFfsnynGh1KE7ZLVB2gStbJrGgu1x1GhqbY7qXkDScB4fKGCChakgpQvGFVXYBRnM3jYkEB9FzehQvF1UgYEJ5qrwuwzDM2b6F1RkYvHQvfPww8Y52zkg9bmWRHg8SMkBmRL3nCXZuZzVew1pTEoUg6ULg9CZmGYemZWsjht9zSy6buZoGgv4wB8yHsWtJem5YRwvh1Rcb1bAmUVsJvnfgm748SPandFwsdvohuirrRMV8VZTqzEdVEufZ1LiG7fdDNN2M3CqTkaLbFaYH5yRHHvpdnJLojZdJetSTdTmJqB6D1zYcbSbGysUerW7tnBPCBjYLz8MfYfZG2mBD4FqnsCKzCPN2CSEfdKaGRkkviCgJxriMpKSsHRhPUNgfNYv25e5L5KMh"
      let validPeerStr2 = "419hUvAwDHXQVJcnDSCW29qwPuNHNzaW1jCa6yLWHx75TN3LwyCJ5Bdzs52ePLdttAqwW9XqKVAiaLEeZgGPajip92ZdtDAjzvomsGADBAumrEMQ6TgG3ic8DhzfN8C4qLbRqAMBUdELQLff3ZnHhRqGj4iURHoRxAuL4SmuKCnTvGJZwJbYDmattG4YaG6FyD6xcpS9kCfsruxKMQYs6HDuuPjQebZpEfArt59w8qC4aRHYBp5u7EkwnkGqcckjuPZMxUmJ9ZubntVPRmMtruKBmQUpaBgWVPyu3ECk4jcfPafvkfHokQQWeKEfApeva8XJnP9xpXoa4RCg7jjKuMv5JB3TqCZZaPxe3NnAdJZ65vRvBVgZ6EyTatxwDngDckrHU51hbCVGJKBSP3dL22ExVoy8Qe5dber9LibTouV3"

      let peerInfo: ReBeacon.peerInfo = {
        "id": "dd0cace3-4d99-daf8-9823-03185a83a15a",
        "type": "p2p-pairing-request",
        "name": "objkt.com",
        "version": "3",
        "publicKey": "66385b04fe60f87d889d5a5af0d61a70f25faf6eaa37f88be8462395cd01c19e",
        "relayServer": "beacon-node-1.diamond.papers.tech",
        "icon": "https://assets.objkt.media/file/assets-002/objkt/objkt-logo.png",
      }->Obj.magic

      let peerInfo2: ReBeacon.peerInfo = {
        "id": "1f321438-6336-ed16-feab-2d495ed647a9",
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
      })

      waitForNextUpdate()
      ->Promise.thenResolve(() =>
        act(() => {
          let (_, _, addPeer, _) = hookResult.result.current
          addPeer(validPeerStr2)->ignore
          clientGetPeers->MockJs.mockImplementation(_ => Promise.resolve([peerInfo2]))->ignore
          ()
        })
      )
      ->Promise.then(waitForNextUpdate)
      ->Promise.thenResolve(_ => {
        let (peers, _, _addPeer, _) = hookResult.result.current
        let expected = clientRemovePeer->MockJs.calls == [peerInfo] && peers == [peerInfo2]
        if expected {
          finish(pass)
        }
      })
      ->ignore
    })
  })

  // testAsync("it returns permissions", finish => {
  //   let client = {
  //     "getPeers": getPeers,
  //     "getPermissions": getPermissions,
  //   }->Obj.magic
  //   let hookResult = renderHook(() => Beacon.usePermissionInfos(client), ())

  //   let waitForNextUpdate: unit => Promise.t<unit> = Obj.magic(hookResult)["waitForNextUpdate"]

  //   waitForNextUpdate()
  //   ->Promise.thenResolve(() => {
  //     let (permisionInfos, _) = hookResult.result.current
  //     if permisionInfos == [mockPermission, mockPermission2] {
  //       finish(pass)
  //     }
  //   })
  //   ->ignore
  // })
})
