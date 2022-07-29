@react.component
let make = (~search) => {
  <DefaultView
    title="No result" subTitle={`There was no result for "${search}". Try a new search.`}
  />
}
