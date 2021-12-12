module Day12

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day12PuzzleInfo <: PuzzleInfo end

"""
Day 12 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day12PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 12 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day12PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(cavename)

Whether cave with name `cavename` is big (returns `True`) or small (returns `False`).
"""
isbigcave(cavename::String) = uppercase(cavename) == cavename

"""
    $(FUNCTIONNAME)(input)

Read cave network from input stream `input`.
"""
function readcavenetwork(input::IO)
    connectedcaves = Dict{String, Set{String}}()
    for line in eachline(input)
        cave1, cave2 = split(line, '-')
        connectedcaves[cave1] = push!(get(connectedcaves, cave1, Set{String}()), cave2)
        connectedcaves[cave2] = push!(get(connectedcaves, cave2, Set{String}()), cave1)
    end
    connectedcaves
end

"""
    $(FUNCTIONNAME)(currentpath, connectedcaves, canrevisitsmallcave)

Recursively explore cave network described by `connectedcaves` (mapping from cave name
to names of connected caves), with current path of caves visited `currentpath` and
whether small caves are currently allowed to be revisited if already visited once
specified by `canrevisitsmallcave`.
"""

function explorecavenetwork!(
    currentpath::Vector{String},
    connectedcaves::Dict{String, Set{String}},
    canrevisitsmallcave::Bool,
)
    paths::Vector{Vector{String}} = []
    for cave in connectedcaves[currentpath[end]]
        if cave == "end"
            push!(paths, [currentpath; cave])
        elseif (
            isbigcave(cave)
            || cave ∉ currentpath
            || (canrevisitsmallcave && cave != "start")
        )
            append!(
                paths,
                explorecavenetwork!(
                    [currentpath; cave],
                    connectedcaves,
                    canrevisitsmallcave && (isbigcave(cave) || cave ∉ currentpath)
                )
            )
        end
    end
    return paths
end

function solve(info::Day12PuzzleInfo)
    connectedcaves = open(readcavenetwork, info.datapath)
    paths = explorecavenetwork!(["start"], connectedcaves, isa(info, Part2PuzzleInfo))
    length(paths)
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day12-1.txt"))) == 10
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day12-2.txt"))) == 19
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day12-3.txt"))) == 226
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day12-1.txt"))) == 36
end

end # module