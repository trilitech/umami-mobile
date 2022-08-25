open Belt
open ReactNative.Style

module RoundImage = {
  @react.component
  let make = (~url, ~size) => {
    let source = ReactNative.Image.uriSource(~uri=url, ())
    <FastImage
      source
      resizeMode=#cover
      style={style(
        ~borderRadius=75.,
        ~height=size->Js.Int.toFloat->dp,
        ~width=size->Js.Int.toFloat->dp,
        (),
      )}
    />
  }
}

@react.component
let make = (~tz1, ~size=80, ~isAccount=false) => {
  let getProfile = Store.useGetTezosProfile()
  let profile = getProfile(tz1)->Option.flatMap(p => p.logo->Js.Nullable.toOption)
  let marginHack = -(size / 4)->Js.Int.toFloat->dp
  <>
    {profile->Option.mapWithDefault(
      isAccount
        ? <UmamiLogoMulti size={size / 2} tz1 />
        : <CommonComponents.Icon
          // Hack on the margin to get same size as maki
            size style={style(~margin=marginHack, ())} name="account-circle-outline"
          />,
      url => <RoundImage url size={size / 2} />,
    )}
  </>
}
