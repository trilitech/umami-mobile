type t = Dark | Light | System

let toString = theme =>
  switch theme {
  | Dark => "dark"
  | Light => "light"
  | System => "system"
  }

let fromString = str =>
  switch str {
  | "dark" => Dark
  | "light" => Light
  | "system" => System
  | _ => Dark
  }
