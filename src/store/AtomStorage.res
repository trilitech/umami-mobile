open Jotai

@module("./atomStorage")
external make: (
  string,
  'value,
) => Atom.t<'value, Jotai.Atom.Actions.set<'value>, [Atom.Tags.r | Atom.Tags.w | Atom.Tags.p]> =
  "makeAtom"

let savedAtom: Jotai.Atom.t<_, _, _> = make("theme2", 3)

let useSavedAtom = () => Jotai.Atom.use(savedAtom)
