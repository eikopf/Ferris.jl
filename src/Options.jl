"""
Provides the [`Option`](@ref) type and its [`None`](@ref) variant, and
also reexports the [`Some`](@ref) type.
"""
module Options
import ..Core: unwrap
export None, Some, Option

struct __None end
Base.show(io::Core.IO, _::__None) = print(io, "None")

"""
    const None

The value which corresponds to an empty [`Option`](@ref).
"""
const None = __None()

"""
    Option{T} = Union{Some{T}, None}

A value of `T` which may or may not exist.
"""
const Option{T} = Union{Some{T}, __None}

function unwrap(opt::Option{T})::T where T
    if opt isa Some
        opt.value
    else
        error(lazy"Called unwrap on None")
    end
end

function Base.map(f, opt::Option{T}) where T
    if opt isa Some
        return Some(f(opt.value))
    else
        return None
    end
end

lift(f) = opt -> map(f, opt)

end