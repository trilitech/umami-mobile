open Jest

open Expect

describe("inputIsValid", () => {
  test("nominal case", () => {
    let input = `bread gauge caught visa film false vehicle fold cheese carry rescue mix stomach deer grocery general payment future attack credit quit diesel tackle pitch`

    expect(ImportSecret.inputIsValid(input))->toEqual(true)
  })

  test("spaces around", () => {
    let input = `   bread gauge caught visa film false vehicle fold cheese carry rescue mix stomach deer grocery general payment future attack credit quit diesel tackle pitch  `

    expect(ImportSecret.inputIsValid(input))->toEqual(true)
  })

  test("multiple spaces and line breaks between and around", () => {
    let input = ` 
    
     bread  
    
     gauge  caught visa film false vehicle fold cheese carry rescue mix stomach deer
      grocery general
       payment future attack credit quit
       diesel tackle pitch `

    expect(ImportSecret.inputIsValid(input))->toEqual(true)
  })

  test("no enough words", () => {
    let input = ` 
    
    
     bread  
    
     gauge  caught visa film false vehicle fold cheese carry rescue mix stomach deer
      grocery general  future attack credit quit
       diesel tackle pitch`

    expect(ImportSecret.inputIsValid(input))->toEqual(false)
  })

  test("too many words", () => {
    let input = ` 
    
    
     bread  
    
     gauge  caught visa film false vehicle fold cheese carry rescue mix stomach deer
      grocery general payment future attack credit quit
       diesel tackle pitch bar`

    expect(ImportSecret.inputIsValid(input))->toEqual(false)
  })
})

describe("formatForMnemonic", () => {
  test("removes whitespaces and newlines", () => {
    let input = ` 
    
     bread  
    
     gauge  caught visa
     
     
      film
       false vehicle fold cheese carry rescue mix stomach deer
      grocery general
       payment future attack credit quit
       diesel tackle 
       pitch 
       `

    let expected = "bread gauge caught visa film false vehicle fold cheese carry rescue mix stomach deer grocery general payment future attack credit quit diesel tackle pitch"
    expect(ImportSecret.formatForMnemonic(input))->toEqual(expected)
  })
})
