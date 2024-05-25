"""
Provides the [`Option`](@ref) type and its [`None`](@ref) variant, and
also reexports the [`Some`](@ref) type.
"""
module Options
# i'm about 54% certain that the `using` keyword here (instead of `import`)
# is loadbearing –– probably for stupid macro reasons
using MLStyle
import ..Core: unwrap
export None, Some, Option

struct __None end

"""
    const None

The value which corresponds to an empty [`Option`](@ref).
"""
const None = __None()

Base.show(io::Core.IO, ::typeof(None)) = print(io, "None")

"""
    Option{T} = Union{Some{T}, None}

A value of `T` which may or may not exist.
"""
const Option{T} = Union{Some{T},__None}

unwrap(some::Some{T}) where T = some.value
unwrap(_::__None) = error("Called unwrap on a None value")

Base.map(f, some::Some{T}) where T = Some(f(some.value))
Base.map(_, _::__None) = None

# pattern matching impl for None
function MLStyle.pattern_uncall(::typeof(None), _, type_params, type_args, args)
  # check that no additional syntax was used
  if isempty(type_params) && isempty(type_args) && isempty(args)
    # return a pattern representing the literal value of None
    return MLStyle.AbstractPatterns.literal(None)
  else
    # otherwise throw an error
    error("None expects no type parameters, type arguments, or actual arguments.")
  end
end

# declare None to be a unit variant
MLStyle.is_enum(::typeof(None)) = true

end
