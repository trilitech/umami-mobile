let filterBySearch = (elements: array<'a>, xf: 'a => string, query) => {
  open Js.String2
  open Belt

  elements->Array.keep(el => {
    let elIdentifier = xf(el)
    query == "" || elIdentifier->toLowerCase->includes(query->toLowerCase)
  })
}
