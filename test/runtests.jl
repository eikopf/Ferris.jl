using Ferris
using Test

@testset "Ferris.jl" begin
  @test Ok{Symbol} <: Result{Symbol,Int}
end
