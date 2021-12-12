module Day10

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day10PuzzleInfo <: PuzzleInfo end

"""
Day 10 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day10PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 10 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day10PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(input)

Read two-dimensional integer (1:9) heightmap data from input stream `input`.
"""
function readheightmap(input::IO)
    reduce(vcat, [parse(Int, c) for c in line]' for line in eachline(input))
end


"""Map from opening character to corresponding closing character."""
const openertoclosermap = Base.ImmutableDict(
    '(' => ')', '[' => ']', '{' => '}', '<' => '>'
)

"""Map from closing character to syntax error points when an illegal character."""
const illegalcharacterpoints = Base.ImmutableDict(
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137,
)

"""
    $(FUNCTIONNAME)(closers)

Score a sequence of closing characters `closers` needed to autocomplete a line.
"""
function scoreclosers(closers::Array{Char})
    closerpoints = Dict{Char, Int}(')' => 1, ']' => 2, '}' => 3, '>' => 4)
    score = 0
    while !isempty(closers)
        score = (score * 5) + closerpoints[pop!(closers)]
    end
    score
end

"""
    $(FUNCTIONNAME)(line)

Get the sequence of expected closing characters for `line`, if it is corrupted and
first illegal character if so.
"""
function expectedclosersandifcorrupted(line)
    expectedclosers::Array{Char} = []
    lineiscorrupted = false
    firstillegalchar = undef
    for c in line
        if haskey(openertoclosermap, c)
            push!(expectedclosers, openertoclosermap[c])
        elseif length(expectedclosers) == 0 || pop!(expectedclosers) != c
            lineiscorrupted = true
            firstillegalchar = c
            break
        end
    end
    expectedclosers, lineiscorrupted, firstillegalchar
end

function solve(info::Part1PuzzleInfo)
    errorscore = 0
    firstillegalchar = undef
    open(info.datapath) do input
        for line in eachline(input)
            _, lineiscorrupted, firstillegalchar = expectedclosersandifcorrupted(line)
            if lineiscorrupted
                errorscore += illegalcharacterpoints[firstillegalchar]
            end
        end
    end
    errorscore
end

function solve(info::Part2PuzzleInfo)
    autocompleterscores::Array{Int} = []
    open(info.datapath) do input
        for line in eachline(input)
            expectedclosers, lineiscorrupted, _ = expectedclosersandifcorrupted(line)
            if !lineiscorrupted
                push!(autocompleterscores, scoreclosers(expectedclosers))
            end
        end
    end
    @assert isodd(length(autocompleterscores)) "Expected odd number of scores"
    sort(autocompleterscores)[(length(autocompleterscores) + 1) ÷ 2]
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day10.txt"))) == 26397
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day10.txt"))) == 288957
end

end # module