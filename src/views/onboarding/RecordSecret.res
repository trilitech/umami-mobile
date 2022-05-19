open Paper

let getRandoms = (arr, amount) => {
  arr->Belt.Array.shuffle->Belt.Array.slice(~offset=0, ~len=amount)
}

let useStack = randoms => {
  let (stack, setStack) = React.useState(_ => randoms)
  let pop = _ => {
    setStack(prev => prev->Belt.Array.slice(~offset=0, ~len={prev->Belt.Array.length - 1}))
  }
  let head = stack->Belt.Array.get(stack->Belt.Array.length - 1)
  (head, pop)
}

let getRandomEls = (~exclude: string, ~amount, arr: array<string>) => {
  arr
  ->Js.Array2.filter(el => {el != exclude})
  ->Belt.Array.shuffle
  ->Belt.Array.slice(~offset=0, ~len=amount)
}

module Redirect = {
  @react.component
  let make = (~navigation) => {
    React.useEffect(() => {
      navigation->NavStacks.OffBoard.Navigation.navigate("NewPassword")
      None
    })
    React.null
  }
}

let useWordIndex = word => {
  let (mnemonic, _) = OnboardingMnemonicState.useMnemonic()
  mnemonic->Belt.Array.getIndexBy(e => e == word)
}

module VerifySecret = {
  @react.component
  let make = (~badAnswers, ~goodAnwser, ~onSolved) => {
    let (selected, setSelected) = React.useState(_ => None)
    let wordIndex = useWordIndex(goodAnwser)
    let caption =
      wordIndex->Belt.Option.mapWithDefault("", i => "Word " ++ Belt.Int.toString(i + 1))

    let allAnswsers = React.useMemo2(() => {
      badAnswers->Belt.Array.concat([goodAnwser])->Belt.Array.shuffle
    }, (goodAnwser, badAnswers))

    let checkAnswer = () => {
      selected
      ->Belt.Option.flatMap(i => {
        allAnswsers->Belt.Array.get(i)
      })
      ->Belt.Option.map(answer => {
        if answer == goodAnwser {
          setSelected(_ => None)
          onSolved()
        }
      })
      ->ignore
    }

    React.useEffect1(() => {
      checkAnswer()
      None
    }, [selected])

    <>
      <OnboardingIntructions
        step="Step 2 of 4"
        title="Record your recovery phrase"
        instructions=" We will now verify that you’ve properly recorded your recovery phrase. To demonstrate this, please select the word that corresponds to each sequence number."
      />
      <Container>
        <Caption> {React.string(caption)} </Caption>
        {allAnswsers
        ->Belt.Array.mapWithIndex((i, s) =>
          <CommonComponents.ListItem
            key=s
            title=s
            selected={switch selected {
            | Some(val) => val === i
            | None => false
            }}
            onPress={_ => setSelected(_ => Some(i))}
          />
        )
        ->React.array}
        <ContinueBtn onPress={_ => onSolved()} text="Next" />
      </Container>
    </>
  }
}

@react.component
let make = (~navigation, ~route as _) => {
  let (mnemonic, _) = OnboardingMnemonicState.useMnemonic()

  let (toGuess, guessed) = mnemonic->getRandoms(3)->useStack

  React.useEffect1(() => {
    if toGuess->Belt.Option.isNone {
      navigation->NavStacks.OffBoard.Navigation.navigate("NewPassword")
    }
    None
  }, [toGuess])

  switch toGuess {
  | Some(goodAnwser) =>
    let badAnswers = getRandomEls(~exclude=goodAnwser, ~amount=4, mnemonic)
    <VerifySecret goodAnwser badAnswers onSolved=guessed />
  | None => <Container> {React.null} </Container>
  }
}
