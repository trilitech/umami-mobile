type t = {
  name: string,
  tz1: Pkh.t,
}

type contactsMap = Belt.Map.String.t<t>
let toArray = m => m->Belt.Map.String.toArray->Belt.Array.map(((_, c)) => c)
