open Jotai

@module("./atomStorage")
external make: (
  string,
  'value,
) => Atom.t<'value, Jotai.Atom.Actions.set<'value>, [Atom.Tags.r | Atom.Tags.w | Atom.Tags.p]> =
  "makeAtom"
