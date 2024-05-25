# Ferris.jl

[![Build Status](https://github.com/eikopf/Ferris.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/eikopf/Ferris.jl/actions/workflows/CI.yml?query=branch%3Amain)

> Familiar forms for the recovering Rustacean.

Ferris provides (among other things)

- the `Option{T}` and `Result{T, E}` types;
- the pattern matching `@match` and `@λ` macros, courtesy of [`MLStyle.jl`](https://github.com/thautwarm/MLStyle.jl);
- some basic operations –– e.g. `map_err`, `unwrap`, `bimap`.
