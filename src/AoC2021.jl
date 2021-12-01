module AoC2021

using ReTest

"""Information associated with a particular puzzle."""
abstract type PuzzleInfo end

"""
    solve(puzzleinfo)

Compute the solution to an Advent of Code puzzle described by `puzzleinfo`.
"""
function solve(::PuzzleInfo) end

end # module
