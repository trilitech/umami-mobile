open Jest
open Expect
open Contact

describe("Deserializers", () => {
  describe("deserializeContacts", () => {
    let expected = Belt.Map.String.fromArray([
      ("foo", {tz1: "foo"->Pkh.unsafeBuild, name: "bob"}),
      ("bar", {tz1: "bar"->Pkh.unsafeBuild, name: "will"}),
      ("baz", {tz1: "baz"->Pkh.unsafeBuild, name: "smith"}),
    ])

    test("deserializeContacts handles old format (array of contacts)", () => {
      let result = StoreConfig.Deserializers.deserializeContacts(`
      [
      {"tz1":"foo", "name":"bob"},
      {"tz1":"bar", "name":"will"},
      {"tz1":"baz", "name":"smith"}
      ]
      `)

      expect(result)->toEqual(expected)
    })

    test("deserializeContacts handles new format (array of tuples to build contacts map)", () => {
      let result = StoreConfig.Deserializers.deserializeContacts(`
      [
      ["foo",{"tz1":"foo", "name":"bob"}],
      ["bar",{"tz1":"bar", "name":"will"}],
      ["baz",{"tz1":"baz", "name":"smith"}]
      ]
      `)

      expect(result)->toEqual(expected)
    })
  })
})
