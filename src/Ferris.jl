module Ferris
include("Core.jl")
include("Results.jl")
include("Options.jl")

import .Core: unwrap, flatten, lift, and, or, ∨, ∧
using .Results, .Options

import MLStyle: @match, @λ

export Ok, Err, Result,
  None, Some, Option, option,
  unwrap, flatten, lift, and, or, ∨, ∧,
  @match, @λ

end
