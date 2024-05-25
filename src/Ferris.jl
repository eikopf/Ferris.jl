module Ferris
include("Core.jl")
include("Results.jl")
include("Options.jl")

import .Core: unwrap, lift
using .Results, .Options

export Ok, Err, Result, None, Some, Option, unwrap, lift


end
