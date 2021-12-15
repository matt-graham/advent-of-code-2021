module Day15

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day15PuzzleInfo <: PuzzleInfo end

"""
Day 15 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day15PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 15 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day15PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(input)

Read two-dimensional integer (1:9) risk level data from input stream `input`.
"""
function readrisklevels(input::IO)
    reduce(vcat, [parse(Int, c) for c in line]' for line in eachline(input))
end

"""
    $(FUNCTIONNAME)(index, shape)

Get iterator over valid neighbour indices to `index` for 2D array with size `shape`.
"""
function neighboursof(index::CartesianIndex{2}, shape::Tuple{Integer, Integer})
    i_offsets(i) = i == 1 ? (1,) : (i == shape[1] ? (-1,) : (-1, 1))
    j_offsets(j) = j == 1 ? (1,) : (j == shape[2] ? (-1,) : (-1, 1))
    Iterators.flatten((
        (index + CartesianIndex(i, 0) for i in i_offsets(index[1])),
        (index + CartesianIndex(0, j) for j in j_offsets(index[2]))
    ))
end

"""
    $(FUNCTIONNAME)(risklevels)

Expand two-dimensional risk levels array by tiling right and downward 5 times, on
each horizontal or vertical shift incrementing the risk levels by 1 and wrapping to 1-9.
"""
function expandrisklevels(risklevels::Array{T, 2}) where T
    shape = size(risklevels)
    expandedrisklevels = Array{T, 2}(undef, size(risklevels) .* 5)
    wrap(x) = mod(x - 1, 9) + 1
    for i in 0:4
        for j in 0:4
            expandedrisklevels[
                (shape[1] * i + 1):(shape[1] * (i + 1)),
                (shape[2] * j + 1):(shape[2] * (j + 1)),
            ] = wrap.(risklevels .+ (i + j))
        end
    end
    expandedrisklevels
end

"""
    $(FUNCTIONNAME)(values, condition)
Get index of minimum value of `values[condition]` within `values`.
"""
argminwhere(values, condition) = findall(condition)[argmin(values[condition])]

function solve(info::Day15PuzzleInfo)
    risklevels = open(readrisklevels, info.datapath)
    isa(info, Part2PuzzleInfo) && (risklevels = expandrisklevels(risklevels))
    visited = falses(size(risklevels))
    totalrisk = fill(typemax(Int), size(risklevels))
    current = CartesianIndex(1, 1)
    target = CartesianIndex(size(risklevels))
    totalrisk[current] = 0
    while !(current == target)
        visited[current] = true
        for neighbour in neighboursof(current, size(risklevels))
            if !visited[neighbour]
                altrisk = totalrisk[current] + risklevels[neighbour]
                altrisk < totalrisk[neighbour] && (totalrisk[neighbour] = altrisk)
            end
        end
        current = argminwhere(totalrisk, .!visited)
    end
    totalrisk[target]
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day15.txt"))) == 40
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day15.txt"))) == 315
end

end # module