@react.component
let make = (~account: Store.account, ~onAccountsPress, ~onPressSend) => {
  // let queryResult = ReactQuery.useQuery(
  //   ReactQuery.queryOptions(
  //     ~queryFn=_ => TaquitoUtils.getBalance(account.tz1),
  //     ~queryKey="balance",
  //     (),
  //   ),
  // )

  // let {refetch} = queryResult
  // Js.Console.log(queryResult)
  // let res =
  //   queryResult.data
  //   ->Belt.Option.flatMap(el => Belt.Float.fromString(el))
  //   ->Belt.Option.map(el => el /. 1000000.)
  //   ->Belt.Option.map(el => Belt.Float.toString(el) ++ " tez")

  // let b = switch res {
  // | Some(d) => d
  // | None => "loading"
  // }
  // React.useEffect1(() => {
  //   let id = Js.Global.setInterval(() => {
  //     refetch({
  //       throwOnError: false,
  //       cancelRefetch: false,
  //     })->ignore
  //     ()
  //   }, 3000)
  //   Some(
  //     () => {
  //       Js.Global.clearInterval(id)
  //       ()
  //     },
  //   )
  // }, [])

  <>
    <Profile onPressToggle={onAccountsPress} onPressSend />
    <Background> <CurrentyBalanceDisplay balance=account.balance /> </Background>
  </>
}
