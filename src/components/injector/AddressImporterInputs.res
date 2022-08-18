open Belt
open CommonComponents
open Paper
open ReactNative.Style
open AddressImporterTypes
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

    <TextInput
      error=invalidInput
      autoCapitalize=#none
      placeholder
      style={style(~flex=1., ())}
      value={txt}
      onChangeText={t => onChange(t->Js.String2.toLowerCase)}
      label
      mode=#flat
      right={rightIcon}
    />
  }
)
module TzDomainRecipient = {
  @react.component
  let make = (~onChange) => {
    let (domainTxt, setDomainTxt) = React.useState(_ => "")
    let (tz1, setTz1) = React.useState(_ => None)
    let notify = SnackBar.useNotification()
    let (loading, setLoading) = React.useState(_ => false)

    let fetchTz1 = React.useCallback4(
      {
        let handleDomainText = t => {
          setLoading(_ => true)
          TezosDomains.getAddress(t)
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
      if TezosDomains.isTezosDomain(domainTxt) {
        fetchTz1(domainTxt)
      } else {
        setTz1(_ => None)
      }
      None
    }, (domainTxt, fetchTz1, setTz1))

    <>
      <Wrapper>
        {makeInput(
          ~txt=domainTxt,
          ~label="Enter tezos domain",
          ~placeholder="Enter tezos domain",
          ~onChange={t => setDomainTxt(_ => t)},
          ~tz1,
        )}
        <ScanAndPaste mode=TezosDomainMode onChange={domain => setDomainTxt(_ => domain)} />
      </Wrapper>
      {loading ? <ActivityIndicator /> : React.null}
    </>
  }
}

module Tz1Recipient = {
  @react.component
  let make = (~onChange) => {
    let (tz1text, setTz1Text) = React.useState(_ => "")

    let tz1 = TaquitoUtils.tz1IsValid(tz1text) ? Some(tz1text) : None

    React.useEffect2(() => {
      onChange(tz1)
      None
    }, (tz1, onChange))

    <>
      <Wrapper>
        {makeInput(
          ~txt=tz1text,
          ~label="Enter tz1 address",
          ~placeholder="Enter tz1 address",
          ~onChange={t => setTz1Text(_ => t)},
          ~tz1,
        )}
        <ScanAndPaste mode=Tz1Mode onChange={tz1 => setTz1Text(_ => tz1)} />
      </Wrapper>
    </>
  }
}
