"""
Provides the [`Result`](@ref) type and its [`Ok`](@ref) and [`Err`](@ref)
variants.
"""
module Results

import ..Core: unwrap
export Ok, Err, Result, isok, iserr, map_err, bimap

"""
The successful variant of a [`Result`](@ref).

# Examples
```julia-repl
julia> Ok(24) isa Ok{Int64}
true

julia> Ok{Symbol} <: Result{Symbol, E} where E
true

julia> Ok{Int} <: Result{AbstractString, E} where E
false

julia> Ok{Bool} <: Result{Float32, Bool}
false
```
"""
struct Ok{T}
  __inner::T
end

"""
The unsuccessful variant of a [`Result`](@ref).

# Examples
```julia-repl
julia> Err(:whoops) isa Err{Symbol}
true

julia> Err{UInt16} <: Result{UInt16, Nothing}
false

julia> Err{String} <: Result{T, String} where T
true
```
"""
struct Err{E}
  __inner::E
end

"""
    Result{T, E} = Union{Ok{T}, Err{E}} where {T, E}

The type of values which may be successful ([`Ok`](@ref)) or
unsuccessful ([`Err`](@ref)).

# Example
Suppose we want to perform type conversions on several values,
and only deal with possible errors afterwards. Exceptions don't
really allow for this, since they expect to be handled immediately.

The solution is therefore to treat errors as values, and wrap the
[`Base.convert`](@ref) function as follows.

```julia
function tryconvert(t::Type{T}, value::U)::Result{T, <:Exception} where {T, U}
    try
        # if the conversion succeeds, just return the resulting value
        return Ok(convert(t, value))
    catch e
        # otherwise, return the exception
        return Err(e)
    end
end
```

Then you can do conversions _without_ needing to wrap everything in try-catch blocks,
and instead defer to type-checking and pattern matching.

```julia-repl
julia> tryconvert(Float32, 1//7)
Ok{Float32}(0.14285715f0)

julia> tryconvert(Float32, :foo)
Err{MethodError}(MethodError(convert, (Float32, :foo), 0x0000000000007afe))
```

Consider a case where you have some heterogenous data that you'd like to convert to
a uniform numeric type, but which has some values that cannot be coerced into numbers.
Using `tryconvert`, you can just filter out these values afterwards and thereby avoid
explicit exception handling.

```julia-repl
julia> [0, 0.1f0, :foo, "bar", 3.6, 0x2, nothing] |>
       (vec -> tryconvert.(Float32, vec)) |>
       filter(isok) .|> unwrap
4-element Vector{Float32}:
 0.0
 0.1
 3.6
 2.0
```
"""
Result{T,E} = Union{Ok{T},Err{E}}

# redefined methods to hide types in REPL, e.g. Ok(:foo) instead of Ok{Symbol}(:foo)
Base.show(io::Core.IO, ok::Ok{T}) where T = print(io, "Ok(", repr(ok.__inner), ")")
Base.show(io::Core.IO, err::Err{E}) where E = print(io, "Err(", repr(err.__inner), ")")

# default to the string constructor if LazyString isn't available
const __error_msg_cons = @static VERSION >= v"1.8" ? LazyString : string

"""
    unwrap(::Result{T, E})

Returns the inner value of the argument if it is [`Ok`](@ref), or
throws an error if it is an [`Err`](@ref).
"""
unwrap(ok::Ok{T}) where T = ok.__inner
unwrap(_::Err) = error(__error_msg_cons("Called unwrap on an Err value: ", res))

Base.map(f, ok::Ok{T}) where T = Ok(f(ok.__inner))
Base.map(_, err::Err) = err

"""
    map_err(f, ::Result{T, E})
  
Applies the given function to the inner value of the [`Result`](@ref) if it is
an [`Err`](@ref) value, or does nothing if it is an [`Ok`](@ref) value.

You can think of [`map_err`](@ref) as the reverse of [`map`](@ref), and the 
second half of [`bimap`](@ref).
"""
map_err(_, ok::Ok) = ok
map_err(f, err::Err{E}) where E = Err(f(err.__inner))

"""
    bimap(f, g, ::Result{T, E})

Applies the first argument (`f`) to the inner value of the [`Result`](@ref) if
it is an [`Ok`](@ref) value, or the second argument (`g`) if it is an [`Err`](@ref) value.
"""
bimap(f, _, ok::Ok{T}) where T = Ok(f(ok.__inner))
bimap(_, f, err::Err{E}) where E = Err(f(err.__inner))

"""
    isok(::Result)::Bool

Returns `true` if the argument is an [`Ok`](@ref) value, or
`false` if it is an [`Err`](@ref) value.
"""
isok(res::Result)::Bool = res isa Ok

"""
    iserr(::Result)::Bool

Returns `true` if the argument is an [`Err`](@ref) value, or
`false` if it is an [`Ok`](@ref) value.
"""
iserr(res::Result)::Bool = res isa Err

end