module Day14

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day14PuzzleInfo <: PuzzleInfo end

"""
Day 14 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day14PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 14 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day14PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(info)

Get number of polymerisation reaction steps to take for puzzle part described by `info`.
"""
function getnumbersteps(::Day14PuzzleInfo) end
getnumbersteps(::Part1PuzzleInfo) = 10
getnumbersteps(::Part2PuzzleInfo) = 40

"""
    $(FUNCTIONNAME)(input)

Read polymer instructions from input stream `input`.
"""
function readpolymerinstructions(input::IO)
    polymertemplate = readuntil(input, "\n\n")
    pairinsertionrules = Dict{String, Char}()
    for line in eachline(input)
        pair, insert = split(line, " -> ")
        pairinsertionrules[pair] = only(insert)
    end
    polymertemplate, pairinsertionrules
end

function solve(info::Day14PuzzleInfo)
    polymer, rules = open(readpolymerinstructions, info.datapath)
    paircounts = Dict{String, Int}()
    for i in 1:(length(polymer) - 1)
        pair = polymer[i:i+1]
        paircounts[pair] = get(paircounts, pair, 0) + 1
    end
    processpair(p) = haskey(rules, p) ? (p[1] * rules[p], rules[p] * p[2]) : (p,)
    for step in 1:getnumbersteps(info)
        newpaircounts = Dict{String, Int}()
        for pair in keys(paircounts)
            for newpair in processpair(pair)
                newpaircounts[newpair] = get(newpaircounts, newpair, 0) + paircounts[pair]
            end
        end
        paircounts = newpaircounts
    end
    elementcounts = Dict{Char, Int}()
    for pair in keys(paircounts)
        elementcounts[pair[1]] = get(elementcounts, pair[1], 0) + paircounts[pair]
    end
    elementcounts[polymer[end]] = get(elementcounts, polymer[end], 0) + 1
    maximum(values(elementcounts)) - minimum(values(elementcounts))
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day14.txt"))) == 1588
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day14.txt"))) == 2188189693529
end

end # module