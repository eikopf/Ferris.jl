# Ferris.jl

[![Build Status](https://github.com/eikopf/Ferris.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/eikopf/Ferris.jl/actions/workflows/CI.yml?query=branch%3Amain)

> Familiar forms for the recovering Rustacean.

Ferris provides (among other things)

- the `Option{T}` and `Result{T, E}` types;
- the pattern matching `@match` and `@λ` macros, courtesy of [`MLStyle.jl`](https://github.com/thautwarm/MLStyle.jl);
- some basic operations –– e.g. `maperr`, `unwrap`, `bimap`.

## Usage

```julia
# using the entire module will give you basically
# everything – this is intended mainly for the REPL
using Ferris

# you can get more fine-grained control by importing from
# the Ferris.Options, Ferris.Results, and Ferris.Core modules

# Options and Results are constructed in a very familiar way
opt1 = Some(0x8)
opt2 = Some(:foo)
opt3 = None

res1 = Ok("bar")
res2 = Ok(13im)
res3 = Err(:baz)

# all the expected operations are still here
unwrap(opt1)    # ==> 0x8
unwrap(opt3)    # ==> throws an error

unwrap(res2)    # ==> 13im
unwrap(res3)    # ==> throws an error

# these are the same operation!
and(res1, res3) # ==> res3
res1 ∧ res3

# so are these!
or(opt1, opt2)  # ==> opt1
opt1 ∨ opt2

# also, you can chain the infix operators
None ∨ None ∨ None ∨ Some(:foo)   # ==> Some(:foo)

# (you can write ∧ and ∨ with \wedge and \vee)

# you can map over Options and Results, though the
# argument order is reversed relative to Rust
map(x -> x ^ 2, None)   # ==> None
map(x -> x - 1, Ok(13)) # ==> Ok(12)

# the reverse argument order allows for do-block syntax
map(Some("blah")) do x
    return x ^ 4
end

# you can also map over the variant Err with maperr
maperr(Err(missing)) do x
    println(x)
end

# if you want to map over both Result variants at the
# same time, you can use bimap
bimap(
    ok -> ok * 2,
    err -> @warn err,
    res2
)

# you can also do this more intuitively with pattern
# matching, using the @match macro
_::Int = @match Some(7) begin
    Some(x) => x^2
    None => 0
end

# pattern matching functions can be written more
# tersely with the @λ macro; the following function
# definitions are all equivalent

func1(some::Some{Int}) = 2 * some.value
func1(::typeof(None))  = 0

function func2(opt::Option{Int})
    @match opt begin
        Some(x) => 2x
        None    => 0
    end
end

const func3 = @λ begin
    Some(x) => 2x
    None    => 0
end

# you can access more complex functionality directly
# from the MLStyle.jl package; Ferris only reexports
# some core relevant macros and functions

# finally, some miscellany

# you can filter Options
const nybl = filter(x -> x < 0x10) ∘ Some
nybl(0xf)   # ==> Some(0xf)
nybl(0x10)  # ==> None

# both Options and Results can be flattened
flatten(Some(None))     # ==> None
flatten(Ok(Ok("blah"))) # ==> Ok("blah")

# errors aren't flattened for reasons that would require me
# to use the word monad at least once – just read the docs
flatten(Err(Err(6)))    # ==> Err(Err(6))

# if you want to map a function over an Option or Result,
# you can use the lift operator from Ferris.Core; the
# following are equivalent operations
map(funcB, map(funcA, Ok(24)))
Ok(24) |> lift(funcA) |> lift(funcB)

# lift is just defined as follows,
lift(f) = x -> map(f, x)
# so it works on anything that map works
# on, like Vectors and iterators
```
