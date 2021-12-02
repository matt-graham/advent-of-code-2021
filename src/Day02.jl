module Day02

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type SubmarineState{T} end

"""
Submarine state for part 1 of puzzle.

$(FIELDS)
"""
mutable struct Part1SubmarineState{T} <: SubmarineState{T}
    """Current horizontal coordinate of submarine."""
    horizontal::T
    """Current depth coordinate of submarine."""
    depth::T
end

"""
Submarine state for part 2 of puzzle.

$(FIELDS)
"""
mutable struct Part2SubmarineState{T} <: SubmarineState{T}
    """Current horizontal coordinate of submarine."""
    horizontal::T
    """Current depth coordinate of submarine."""
    depth::T
    """Current aim of submarine."""
    aim::T
end

"""
    $(FUNCTIONNAME)(command, statetype)

Parse command string `command` for submarine state with type `statetype`.
"""
function parsecommand(command::AbstractString, statetype::Type)
    direction, distance_string = split(command)
    distance = parse(statetype, distance_string)
    direction, distance
end

function forward_stateupdate!(state::Part1SubmarineState{T}, distance::T) where {T}
    state.horizontal += distance
end

function down_stateupdate!(state::Part1SubmarineState{T}, distance::T) where {T}
    state.depth += distance
end

function up_stateupdate!(state::Part1SubmarineState{T}, distance::T) where {T}
    state.depth -= distance
end

function forward_stateupdate!(state::Part2SubmarineState{T}, distance::T) where {T}
    state.horizontal += distance
    state.depth += state.aim * distance
end

function down_stateupdate!(state::Part2SubmarineState{T}, distance::T) where {T}
    state.aim += distance
end

function up_stateupdate!(state::Part2SubmarineState{T}, distance::T) where {T}
    state.aim -= distance
end

const stateupdates = Dict(
    "forward" => forward_stateupdate!,
    "down" => down_stateupdate!,
    "up" => up_stateupdate!
)

"""
    $(FUNCTIONNAME)(state, command)

Apply update described by command string `command` to submarine state `state` inplace.
"""
function updatestate!(
    state::SubmarineState{T},
    command::AbstractString,
) where {T}
    direction, distance = parsecommand(command, T)
    stateupdates[direction](state, distance)
    return
end

abstract type Day02PuzzleInfo <: PuzzleInfo end

"""
Day 2 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day02PuzzleInfo
    """Path to input data file."""
    datapath :: AbstractString
end

"""
Day 2 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day02PuzzleInfo
    """Path to input data file."""
    datapath :: AbstractString
end

"""
    $(FUNCTIONNAME)(info)

Get initial submarine state for puzzle part described by `info`.
"""
function getinitialstate(::Day02PuzzleInfo) end

getinitialstate(::Part1PuzzleInfo) = Part1SubmarineState{Int}(0, 0)

getinitialstate(::Part2PuzzleInfo) = Part2SubmarineState{Int}(0, 0, 0)

function solve(info::Day02PuzzleInfo)
    state = getinitialstate(info)
    open(info.datapath, "r") do input
        for command in eachline(input)
            updatestate!(state, command)
        end
    end
    state.horizontal * state.depth
end

@testset "Day02" begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day02.txt"))) == 150
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day02.txt"))) == 900
end

end # module