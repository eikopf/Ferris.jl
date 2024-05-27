"""
Provides the [`Option`](@ref) type and its [`None`](@ref) variant, and
also reexports the [`Some`](@ref) type.
"""
module Options
# i'm about 54% certain that the `using` keyword here (instead of `import`)
# is loadbearing –– probably for stupid macro reasons
using MLStyle
import ..Core: unwrap, flatten, and, or
export None, Some, Option

struct __None end

"""
    const None

The value which corresponds to an empty [`Option`](@ref).
"""
const None = __None()

Base.show(io::Core.IO, ::Type{typeof(None)}) = print(io, "typeof(None)")
Base.show(io::Core.IO, ::typeof(None)) = print(io, "None")

"""
    Option{T} = Union{Some{T}, typeof(None)}

A value of `T` which may be [`None`](@ref)
"""
const Option{T} = Union{
  Some{T},
  typeof(None)
}

"""
    unwrap(opt::Option{T})::T

Returns the inner value of `opt` if it is a [`Some`](@ref) value, or throws
an error if it is [`None`](@ref).
"""
unwrap(some::Some{T}) where {T} = some.value
unwrap(::typeof(None)) = error("Called unwrap on a None value")

"""
    flatten(::Option{Option{T}})::Option{T}

Maps `Some(Some(x))` to `Some(x)`, and `Some(None)` and `None` to `None`.
"""
flatten(some::Some{Some{T}}) where {T} = some.value
flatten(::Some{typeof(None)}) = None
flatten(::typeof(None)) = None

and(::Some{T}, rhs::Option{T}) where {T} = rhs
and(::typeof(None), ::Option) = None

or(lhs::Some{T}, ::Option{T}) where {T} = lhs
or(::typeof(None), rhs::Option) = rhs

Base.map(f, some::Some{T}) where {T} = Some(f(some.value))
Base.map(_, ::typeof(None)) = None

# PATTERN MATCHING BOILERPLATE

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
