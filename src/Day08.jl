module Day08

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day08PuzzleInfo <: PuzzleInfo end

"""
Day 8 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day08PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 8 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day08PuzzleInfo
    """Path to input data file."""
    datapath::String
end

function solve(info::Part1PuzzleInfo)
    uniquepatterndigitscount = 0
    open(info.datapath) do input
        for line in eachline(input)
            patterns, outputs = map(split, split(line, " | "))
            uniquepatterndigitscount += count((s -> length(s) in (2, 3, 4, 7)), outputs)
        end
    end
    uniquepatterndigitscount
end

function findbylength(patterns, length_)
    patterns[findall(p -> length(p) == length_, patterns)]
end

function findbyintersectionlength(searchpatterns, testpattern, length_)
    searchpatterns[
        findfirst(p -> length(intersect(p, testpattern)) == length_, searchpatterns)
    ]
end

function solve(info::Part2PuzzleInfo)
    total = 0
    valueof = Dict{Set{Char}, Int}()
    patternof = Dict{Int, Set{Char}}()
    function addtomaps!(pattern, value)
        valueof[Set(pattern)] = value
        patternof[value] = Set(pattern)
    end
    open(info.datapath) do input
        for line in eachline(input)
            patterns, outputs = map(split, split(line, " | "))
            addtomaps!(only(findbylength(patterns, 2)), 1)
            addtomaps!(only(findbylength(patterns, 3)), 7)
            addtomaps!(only(findbylength(patterns, 4)), 4)
            addtomaps!(only(findbylength(patterns, 7)), 8)
            patterns_for_069 = map(Set, findbylength(patterns, 6))
            addtomaps!(findbyintersectionlength(patterns_for_069, patternof[1], 1), 6)
            addtomaps!(findbyintersectionlength(patterns_for_069, patternof[4], 4), 9)
            addtomaps!(only(setdiff(patterns_for_069, [patternof[6], patternof[9]])), 0)
            patterns_for_235 = map(Set, findbylength(patterns, 5))
            addtomaps!(findbyintersectionlength(patterns_for_235, patternof[1], 2), 3)
            addtomaps!(findbyintersectionlength(patterns_for_235, patternof[6], 5), 5)
            addtomaps!(only(setdiff(patterns_for_235, [patternof[3], patternof[5]])), 2)
            total += parse(Int, join(valueof[Set(pattern)] for pattern in outputs))
            empty!(valueof)
            empty!(patternof)
        end
    end
    total
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day08.txt"))) == 26
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day08.txt"))) == 61229
end

end # module