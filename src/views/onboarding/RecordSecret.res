let getRandoms = (arr, amount) => {
  arr->Belt.Array.shuffle->Belt.Array.slice(~offset=0, ~len=amount)
}

let useStack = arr => {
  let (stack, setStack) = React.useState(_ => arr)

  let tail = stack->Belt.Array.get(stack->Belt.Array.length - 1)
  let pop = _ => {
    setStack(prev => prev->Belt.Array.slice(~offset=0, ~len={prev->Belt.Array.length - 1}))
    tail
  }
  pop
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
  let (mnemonic, _) = DangerousMnemonicHooks.useMnemonic()
  mnemonic->Belt.Array.getIndexBy(e => e == word)
}

module VerifySecret = {
  @react.component
  let make = (~badAnswers, ~goodAnwser, ~onSolved, ~onSkipAll) => {
    let (selected, setSelected) = React.useState(_ => None)
    let wordIndex = useWordIndex(goodAnwser)
    let notify = SnackBar.useNotification()
    let caption =
      wordIndex->Belt.Option.mapWithDefault("", i => "Word " ++ Belt.Int.toString(i + 1))

    let errorColor = UmamiThemeProvider.useErrorColor()
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
        } else {
          notify("Wrong answer!")
        }
      })
      ->ignore
    }

    <>
      <InstructionsPanel
        step="Step 2 of 4"
        title="Record your recovery phrase"
        instructions=" We will now verify that you’ve properly recorded your recovery phrase. To demonstrate this, please select the word that corresponds to each sequence number."
      />
      <Container>
        <Paper.Caption> {React.string(caption)} </Paper.Caption>
        {allAnswsers
        ->Belt.Array.mapWithIndex((i, s) =>
          <CommonComponents.ListItem
            testID="mnemonic-word"
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
        <ContinueBtn
          onPress={_ => {
            checkAnswer()
          }}
          text="Next"
        />
        <ContinueBtn color=errorColor onPress={_ => onSkipAll()} text="YOLO (not recommended)" />
      </Container>
    </>
  }
}

let useWordsToGuess = mnemonic => mnemonic->getRandoms(4)->useStack

module PureRecordSecret = {
  @react.component
  let make = (~onFinished, ~mnemonic) => {
    let getWord = useWordsToGuess(mnemonic)
    let (wordToGuess, setWordToGuess) = React.useState(_ => getWord())

    React.useEffect1(() => {
      if wordToGuess->Belt.Option.isNone {
        onFinished()
      }
      None
    }, [wordToGuess])

    let handleSovled = () => {
      let nextWord = getWord()
      setWordToGuess(_ => nextWord)
    }

    let skipAll = () => setWordToGuess(_ => None)

    switch wordToGuess {
    | Some(goodAnwser) =>
      let badAnswers = getRandomEls(~exclude=goodAnwser, ~amount=4, mnemonic)
      <VerifySecret goodAnwser badAnswers onSolved=handleSovled onSkipAll=skipAll />
    | None => <Container> {React.null} </Container>
    }
  }
}

@react.component
let make = (~navigation, ~route as _) => {
  let (mnemonic, _) = DangerousMnemonicHooks.useMnemonic()

  <PureRecordSecret
    mnemonic
    onFinished={() => {
      navigation->NavStacks.OffBoard.Navigation.navigate("NewPassword")
    }}
  />
}
