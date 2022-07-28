open CommonComponents
open Belt
open ReactNative.Style

module FABadge = {
  @react.component
  let make = (~standard) => {
    let borderColor = ThemeProvider.useDisabledColor()
    <ReactNative.View
      style={style(
        ~borderWidth=1.,
        ~borderRadius=4.,
        ~paddingHorizontal=4.->dp,
        ~marginHorizontal=8.->dp,
        ~borderColor,
        (),
      )}>
      <Paper.Caption> {React.string(standard)} </Paper.Caption>
    </ReactNative.View>
  }
}

module CurrencyItem = {
  @react.component
  let make = (~asset: Asset.t, ~onPress) => {
    let prettyDisplay = asset->Asset.getPrettyString
    let icon = asset->Asset.isToken->AssetLogo.getLogo
    let standardBadge =
      asset->Asset.getStandard->Option.mapWithDefault(React.null, standard => <FABadge standard />)

    <CustomListItem
      height=70.
      left={icon}
      center={<Wrapper>
        <Paper.Title style={style()}> {React.string(prettyDisplay)} </Paper.Title> {standardBadge}
      </Wrapper>}
      onPress
      right={<ChevronRight />}
    />
  }
}

// Get Assets to display in main screen
// Exclude NFTs
let getAssets = (balance: option<int>, tokens: array<Token.t>) => {
  open Asset
  let tezAsset = balance->Option.map(b => Tez(b))->Option.mapWithDefault([], a => [a])
  let tokenAssets = tokens->Array.keep(t => !(t->Token.isNft))->Array.map(t => Token(t))
  Array.concat(tezAsset, tokenAssets)
}

@react.component
let make = (~balance: option<int>, ~onPress, ~tokens) => {
  let assets = getAssets(balance, tokens)
  <>
    {assets
    ->Array.map(asset =>
      <CurrencyItem key={asset->Asset.getPrettyString} asset onPress={_ => onPress(asset)} />
    )
    ->React.array}
  </>
}
