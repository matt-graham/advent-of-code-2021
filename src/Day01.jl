module Day01

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

"""
    $(FUNCTIONNAME)(values)

Count the number of positive differences between successive elements in `values`.

# Examples
```jldoctest; setup = :(using AoC2021.Day01: $(FUNCTIONNAME))
julia> $(FUNCTIONNAME)([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
7
```
"""
function countincreases(values::AbstractVector)
    sum(diff(values) .> 0)
end

"""
    $(FUNCTIONNAME)(values, windowsize)

Stack sliding windows of size `windowsize` of a 1D array `values` in to a 2D array.

# Examples
```jldoctest; setup = :(using AoC2021.Day01: $(FUNCTIONNAME))
julia> $(FUNCTIONNAME)([199, 200, 208, 210, 200, 207, 240, 269, 260, 263], 3)
8×3 Matrix{Int64}:
 199  200  208
 200  208  210
 208  210  200
 210  200  207
 200  207  240
 207  240  269
 240  269  260
 269  260  263
```
"""
function slidingwindows(values::AbstractVector, windowsize::Integer)
    reduce(vcat, (values[i:i+windowsize-1]' for i in 1:length(values)-windowsize+1))
end

"""
    $(FUNCTIONNAME)(input, type)

Read array from input stream `input` with one value of type `type` per line.
"""
function readarraydata(input::IO, type::Type)
    [parse(type, value) for value in eachline(input)]
end

abstract type Day01PuzzleInfo <: PuzzleInfo end

"""
Day 1 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day01PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 1 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day01PuzzleInfo
    """Path to input data file."""
    datapath::String
    """Size of sliding window to use."""
    windowsize::Int
end

Part2PuzzleInfo(datapath) = Part2PuzzleInfo(datapath, 3)

"""
    $(FUNCTIONNAME)(depths, info)

Apply preprocessing to depths data in `data` for puzzle part with information `info`.
"""
preprocessdepths(depths::AbstractVector, ::Day01PuzzleInfo) = depths

function preprocessdepths(depths::AbstractVector, info::Part2PuzzleInfo)
    vec(sum(slidingwindows(depths, info.windowsize), dims=2))
end

function solve(info::Day01PuzzleInfo)
    depths = open(info.datapath, "r") do input
        readarraydata(input, Int)
    end
    processeddepths = preprocessdepths(depths, info)
    countincreases(processeddepths)
end

@testset "Day01" begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day01.txt"))) == 7
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day01.txt"), 3)) == 5
end

end # module

