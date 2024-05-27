"""
Provides the [`Option`](@ref) type and its [`None`](@ref) variant, and
also reexports the [`Some`](@ref) type.
"""
module Options
# i'm about 54% certain that the `using` keyword here (instead of `import`)
# is loadbearing –– probably for stupid macro reasons
using MLStyle
import ..Core: unwrap, flatten, and, or
export None, Some, Option, option

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

A value of `T` which may be [`None`](@ref).

# Example
Consider a function that takes bytes (i.e. `UInt8` values) and tries
to convert them into nybls.

> A _nybl_ (also _nibble_ or _nybbl_) is a 4-bit unsigned integer.

Using exceptions, this might be written as follows.
```julia
function nybl(byte::UInt8)
  if byte < 0x10
    return byte
  else
    error(lazy"Cannot convert \$byte into a nybl.")
  end
end
```

But exceptions are annoying, particularly when you already know some
of your input values are probably going to be invalid nybls. So instead,
we can rewrite the function as follows.

```julia
using Ferris.Options

function nybl(byte::UInt8)::Option{UInt8}
  if byte < 0x10
    Some(byte)
  else
    None
  end
end

# if you really want to be terse, this also works
const nybl = filter(<(0x10)) ∘ Some
```
"""
const Option{T} = Union{
  Some{T},
  typeof(None)
}

"""
    option(x)::Option{T}

Converts the given value to an appropriate [`Option`](@ref), usually a [`Some`](@ref).

Treat this function like [`string`](@ref), in the sense that it should be extended for
appropriate types. In general, you only need to add a new method to `option` if your
type is semantically equivalent to `None`; in all other cases you can just rely on the
"default" method, which just applies the `Some` constructor.

By default, the only types mapped to [`None`](@ref) are
1. `typeof(None)`;
2. [`Nothing`](@ref);
3. [`Missing`](@ref).
"""
function option end
option(::typeof(None)) = None
option(::Nothing) = None
option(::Missing) = None
option(x) = Some(x)

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

Base.filter(p, some::Some{T}) where {T} = p(some.value) ? some : None
Base.filter(_, ::typeof(None)) = None

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
