type t = Tez(int) | Token(Token.t)

let isTez = amount =>
  switch amount {
  | Tez(_) => true
  | _ => false
  }
