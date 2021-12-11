module Day11

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day11PuzzleInfo <: PuzzleInfo end

"""
Day 11 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day11PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 11 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day11PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(input)

Read two-dimensional integer (1:9) energy level data from input stream `input`.
"""
function readenergylevels(input::IO)
    reduce(vcat, [parse(Int, c) for c in line]' for line in eachline(input))
end

"""
    $(FUNCTIONNAME)(index, shape)

Get iterator over valid offset indices at index `index` for 2D array with size `shape`.
"""
function offsetsat(index::CartesianIndex{2}, shape::Tuple{Integer, Integer})
    [
        CartesianIndex(i, j)
        for i in (index[1] > 1 ? -1 : 0):(index[1] < shape[1] ? 1 : 0)
        for j in (index[2] > 1 ? -1 : 0):(index[2] < shape[2] ? 1 : 0)
    ]
end

"""
    $(FUNCTIONNAME)(energylevels)

Step dumbo octopus flashing model forward given current energy levels `energylevels`.
Returns the set of indices corresponding to octopi which flashed during step.
"""
function stepmodel!(energylevels::Array{T, 2}) where T <: Integer
    energylevels .+= 1
    flashindices = findall(energylevels .> 9)
    energylevels[flashindices] .= 0
    flashed = Set(flashindices)
    while length(flashindices) > 0
        for flashindex in flashindices
            for offset in offsetsat(flashindex, size(energylevels))
                adjacentindex = flashindex + offset
                if adjacentindex ∉ flashed
                    energylevels[flashindex + offset] += 1
                end
            end
        end
        flashindices = findall(energylevels .> 9)
        energylevels[flashindices] .= 0
        union!(flashed, flashindices)
    end
    flashed
end

function solve(info::Part1PuzzleInfo)
    energylevels = open(readenergylevels, info.datapath)
    numflashes = 0
    for step in 1:100
        flashed = stepmodel!(energylevels)
        numflashes += length(flashed)
    end
    numflashes
end

function solve(info::Part2PuzzleInfo)
    energylevels = open(readenergylevels, info.datapath)
    step = 0
    while !all(energylevels .== 0)
        stepmodel!(energylevels)
        step += 1
    end
    step
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day11.txt"))) == 1656
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day11.txt"))) == 195
end

end # module