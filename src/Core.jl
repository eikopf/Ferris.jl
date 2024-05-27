"""
    Ferris.Core

This module provides common function definitions, largely the faux-monadic
methods that both `Result` and `Option` provide.
"""
module Core
export unwrap, flatten, and, or, ∧, ∨, lift

"""
    unwrap(::M{T})::T

Unwraps the given container, throwing an error if there is no inner value.
"""
function unwrap end

"""
    flatten(::M{M{T}})::M{T}

Converts a doubly-nested container into a single container. In the functional
context this is the monadic `join` or `μ` operator, with type `m m a -> m a`.
"""
function flatten end

"""
    and(::M{T}, ::M{T})::M{T}

Returns the second argument if the first argument is _truthy_, or else the first
argument. This is the semantic opposite of [`or`](@ref), in that it returns the
second argument if and only if the first argument _succeeds_.
"""
function and end

"""
    a ∧ b = and(a, b)

Infix synonym for [`and`](@ref); refer to `?Ferris.Core.and` for details.
"""
const ∧ = and

"""
    or(::M{T}, ::M{T})::M{T}

Returns the first argument if it is _truthy_, or else the second argument. This
is analogous to the `<|>` operator from the `Alternative` typeclass in Haskell.
"""
function or end

"""
    a ∨ b = or(a, b)

Infix synonym for [`or`](@ref); refer to `?Ferris.Core.or` for details.
"""
const ∨ = or

"""
    lift(f) = x -> map(f, x)

Lifts a given function into the inferred monad*ish* context.
"""
lift(f) = x -> map(f, x)
end
