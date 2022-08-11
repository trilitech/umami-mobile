type debouncedFn<'a> = 'a => unit

@module("lodash")
external debounce: (~cb: 'a => unit, ~wait: int=?, unit) => debouncedFn<'a> = "debounce"
