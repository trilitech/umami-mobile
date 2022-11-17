open Belt
open CommonComponents
open Paper
open ReactNative.Style
open Lodash

%%private(
  let makeInput = (~txt, ~tz1, ~placeholder, ~label, ~onChange) => {
    open Colors.Light
    let invalidInput = txt != "" && tz1->Option.isNone

    let rightIcon = if tz1->Option.isSome {
      <TextInput.Icon color=positive name={Paper.Icon.name("check")} />
    } else if invalidInput {
      <TextInput.Icon color=negative name={Paper.Icon.name("alert-circle-outline")} />
    } else {
      React.null
    }

    <UI.Input
      error=invalidInput
      autoCapitalize=#none
      placeholder
      style={style(~flex=1., ())}
      value={txt}
      onChangeText={t => onChange(t->Js.String2.toLowerCase)}
      label
      right={rightIcon}
    />
  }
)

let renderTz1 = (tz1: option<Pkh.t>) =>
  tz1->Helpers.reactFold(tz1 => <Caption> {tz1->Pkh.toPretty->React.string} </Caption>)

module TzDomainRecipient = {
  @react.component
  let make = (~onChange: option<Pkh.t> => unit) => {
    let (addressTxt, setAddressTxt) = React.useState(_ => "")
    let (tz1, setTz1) = React.useState(_ => None)
    let notify = SnackBar.useNotification()
    let (loading, setLoading) = React.useState(_ => false)

    let fetchTz1 = React.useCallback4(
      {
        let handleDomainText = t => {
          setLoading(_ => true)
          TezosDomainsAPI.getAddress(t)
          ->Promise.thenResolve(tz1 => setTz1(_ => tz1))
          ->Promise.catch(exn => {
            notify("Failed to fetch tezos domain. " ++ exn->Helpers.getMessage)
            Promise.resolve()
          })
          ->Promise.finally(_ => setLoading(_ => false))
          ->ignore
        }

        debounce(~cb=handleDomainText, ~wait=1000, ())
      },
      (onChange, setTz1, notify, setLoading),
    )

    React.useEffect2(() => {
      onChange(tz1)
      None
    }, (tz1, onChange))

    React.useEffect3(() => {
      if TezosDomainsAPI.isTezosDomain(addressTxt) {
        fetchTz1(addressTxt)
      } else {
        setTz1(_ => Pkh.buildOption(addressTxt))
      }

      None
    }, (addressTxt, fetchTz1, setTz1))

    <>
      <Wrapper>
        {makeInput(
          ~txt=addressTxt,
          ~label="Address or Tezos domain",
          ~placeholder="Enter tz address or tezos domain",
          ~onChange={t => setAddressTxt(_ => t)},
          ~tz1,
        )}
        <ScanAndPaste
          onChange={a => setAddressTxt(_ => a)}
          style={array([StyleUtils.makeTopMargin(~size=2, ()), StyleUtils.makeLeftMargin()])}
        />
      </Wrapper>
      <Wrapper
        justifyContent=#center
        style={array([StyleUtils.makeVMargin(), style(~height=24.->dp, ())])}>
        {loading ? <ActivityIndicator /> : renderTz1(tz1)}
      </Wrapper>
    </>
  }
}
