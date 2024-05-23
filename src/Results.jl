"""
Provides the [`Result`](@ref) type and its [`Ok`](@ref) and [`Err`](@ref)
variants.
"""
module Results

import ..Core: unwrap
export Ok, Err, Result, isok

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
[`Base.convert`] function as follows.

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
Result{T, E} = Union{Ok{T}, Err{E}}

"""
    unwrap(::Result{T, E})

Returns the inner value of the argument if it is [`Ok`](@ref), or
throws an error if it is an [`Err`](@ref).
"""
function unwrap(res::Result{T, E})::T where {T, E}
    if isok(res)
        return res.__inner
    else
        error(lazy"Called unwrap on an Err: $res")
    end
end

"""
    isok(::Result)::Bool

Returns `true` if the argument is an [`Ok`](@ref) value, or
`false` if it is an [`Err`](@ref) value.
"""
isok(res::Result)::Bool = res isa Ok

Base.map(f, res::Result{T, E}) where {
    T, E
} = if isok(res)
    Ok(f(res.__inner))
else
    res
end
end