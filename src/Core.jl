module Core
export unwrap, lift

"""
    unwrap(::Foo{T[, ...]})::T

Unwraps the given container, or throws an error if there is no inner value.
"""
function unwrap end

"""
    lift(f) = x -> map(f, x)

Lifts a given function into the inferred monad*ish* context.
"""
lift(f) = x -> map(f, x)
end
