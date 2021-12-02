module AoC2021

using ReTest
using DocStringExtensions

TEST_DATA_DIRECTORY = joinpath(dirname(@__DIR__), "test_data")

"""Information associated with a particular puzzle."""
abstract type PuzzleInfo end

"""
    $(FUNCTIONNAME)(puzzleinfo)

Compute the solution to an Advent of Code puzzle described by `puzzleinfo`.
"""
function solve(::PuzzleInfo) end

for srcfile in readdir(joinpath(@__DIR__))
    if occursin(r"^Day[0-9]{2}\.jl", srcfile)
        include(srcfile)
    end
end

end # module
