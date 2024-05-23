module Core
    export unwrap

    """
        unwrap(::Foo{T[, ...]})::T
    
    Unwraps the given container, or throws an error if there is no inner value.
    """
    function unwrap end
end