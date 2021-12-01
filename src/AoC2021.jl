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

include("Day01.jl")

end # module
