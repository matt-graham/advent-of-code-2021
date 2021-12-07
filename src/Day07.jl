module Day07

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day07PuzzleInfo <: PuzzleInfo end

"""
Day 7 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day07PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 7 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day07PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(info, distances)

Calculate fuel consumed for puzzle part specified by `info` and distances `distances`.
"""
function fuelconsumption(::Day07PuzzleInfo, distances::AbstractArray{T}) where {T} end

function fuelconsumption(::Part1PuzzleInfo, distances::AbstractArray{T}) where {T}
    distances
end

function fuelconsumption(::Part2PuzzleInfo, distances::AbstractArray{T}) where {T}
    ((distances .+ 1) .* distances) .÷ 2
end

function solve(info::Day07PuzzleInfo)
    agecounts = Dict{Int, BigInt}(age => 0 for age in 0:8)
    crabpositions = open(info.datapath) do input
        [parse(Int, position) for position in split(readline(input), ',')]
    end
    crabdistances = abs.(
        crabpositions .- (minimum(crabpositions):maximum(crabpositions))'
    )
    minimum(sum(fuelconsumption(info, crabdistances), dims=1))
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day07.txt"))) == 37
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day07.txt"))) == 168
end

end # module