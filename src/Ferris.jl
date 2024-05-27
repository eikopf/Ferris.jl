module Ferris
include("Core.jl")
include("Results.jl")
include("Options.jl")

import .Core: unwrap, flatten, lift
using .Results, .Options

import MLStyle: @match, @λ

export Ok, Err, Result,
  None, Some, Option,
  unwrap, flatten, lift,
  @match, @λ

end
