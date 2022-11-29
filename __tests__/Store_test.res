open Jest
open Expect
open Testing

let useCounter = () => {
  let (count, setCount) = React.useState(_ => 0)

  let increment = () => setCount(x => x + 1)

  (count, increment)
}

open Network
describe("Store", () => {
  describe("Network", () => {
    test("useNetwork has Mainnet default value", () => {
      let {result} = renderHook(Store.useNetwork, ())
      let (network, _) = result.current
      expect(network)->toBe(Mainnet)
    })

    test("network can be changed", () => {
      let {result} = renderHook(Store.useNetwork, ())
      act(() => {
        let (_, setNetwork) = result.current
        setNetwork(_ => Ghostnet)
      })
      let (network, _) = result.current
      expect(network)->toBe(Ghostnet)
    })

    test("setting network resets nodeIndex and operations", () => {
      let networkHook = renderHook(Store.useNetwork, ()).result
      let nodeIndexHook = renderHook(Store.useNodeIndex, ()).result
      let operationsHook = renderHook(Store.useOperations, ()).result

      // Setup
      act(() => {
        let (_, setNodeIndex) = nodeIndexHook.current
        let (_, setOperations) = operationsHook.current
        setNodeIndex(_ => 2)
        let ops = Belt.Map.String.fromArray([("bar", {"src": "foo"})])
        setOperations(ops->Obj.magic)
      })

      act(() => {
        let (_, setNetwork) = networkHook.current
        setNetwork(_ => Mainnet)
      })

      let (nodeIndex, _) = nodeIndexHook.current
      let (operations, _) = operationsHook.current
      expect((nodeIndex, operations))->toEqual((0, Belt.Map.String.fromArray([])))
    })
  })

  describe("SelectedAccount", () => {
    test("First account is returned by default", () => {
      let selectedAccountHook = renderHook(Store.useSelectedAccount, ()).result
      let accountsHook = renderHook(Store.useAccounts, ()).result

      // Setup
      act(() => {
        let (_, setAccounts) = accountsHook.current
        let accounts = [{"name": "first"}, {"name": "second"}]
        setAccounts(_ => accounts->Obj.magic)
      })

      let (account, _) = selectedAccountHook.current
      expect(account)->toEqual({"name": "first"}->Obj.magic)
    })

    test("returns selected account by index", () => {
      let selectedAccountHook = renderHook(Store.useSelectedAccount, ()).result
      let accountsHook = renderHook(Store.useAccounts, ()).result

      // Setup
      act(() => {
        let (_, setAccounts) = accountsHook.current
        let accounts = [{"name": "first"}, {"name": "second"}]
        setAccounts(_ => accounts->Obj.magic)
      })

      act(() => {
        let (_, setSelectedAccount) = selectedAccountHook.current
        setSelectedAccount(_ => 1)
      })

      let (account, _) = selectedAccountHook.current
      expect(account)->toEqual({"name": "second"}->Obj.magic)
    })

    test("selecting account resets operations", () => {
      let selectedAccountHook = renderHook(Store.useSelectedAccount, ()).result
      let operationsHook = renderHook(Store.useOperations, ()).result

      // Setup
      act(() => {
        let (_, setOperations) = operationsHook.current
        let ops = Belt.Map.String.fromArray([("bar", {"src": "foo"})])
        setOperations(ops->Obj.magic)
      })

      // Action
      act(() => {
        let (_, seSelectedAccount) = selectedAccountHook.current
        seSelectedAccount(_ => 1)
      })

      let (operations, _) = operationsHook.current
      expect(operations)->toEqual(Belt.Map.String.fromArray([]))
    })
  })
})
