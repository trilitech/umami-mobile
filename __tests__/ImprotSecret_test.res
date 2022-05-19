open Jest

open Expect

describe("passPhraseIsValid", () => {
  test("nominal case", () => {
    let input = `bread gauge caught visa film false vehicle fold cheese carry rescue mix stomach deer grocery general payment future attack credit quit diesel tackle pitch`

    expect(ImportSecret.backupPharseIsValid(input))->toEqual(true)
  })

  test("spaces around", () => {
    let input = `   bread gauge caught visa film false vehicle fold cheese carry rescue mix stomach deer grocery general payment future attack credit quit diesel tackle pitch  `

    expect(ImportSecret.backupPharseIsValid(input))->toEqual(true)
  })

  test("multiple spaces and line breaks between and around", () => {
    let input = ` 
    
    
     bread  
    
     gauge  caught visa film false vehicle fold cheese carry rescue mix stomach deer
      grocery general payment future attack credit quit
       diesel tackle pitch`

    expect(ImportSecret.backupPharseIsValid(input))->toEqual(true)
  })

  test("no enough words", () => {
    let input = ` 
    
    
     bread  
    
     gauge  caught visa film false vehicle fold cheese carry rescue mix stomach deer
      grocery general  future attack credit quit
       diesel tackle pitch`

    expect(ImportSecret.backupPharseIsValid(input))->toEqual(false)
  })

  test("too many words", () => {
    let input = ` 
    
    
     bread  
    
     gauge  caught visa film false vehicle fold cheese carry rescue mix stomach deer
      grocery general payment future attack credit quit
       diesel tackle pitch bar`

    expect(ImportSecret.backupPharseIsValid(input))->toEqual(false)
  })
})
