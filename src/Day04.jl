module Day04

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day04PuzzleInfo <: PuzzleInfo end

"""
Day 4 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day04PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 4 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day04PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(input)

Read bingo game data from input stream `input`.

First line of input is assumed to be comma-delimited list of drawn (interger) numbers.

Subsequent lines corresponds to game boards, with each 5x5 board separated by a blank
new line (and separated by a blank new line from the draws), with each row of numbers in
each board separated by a new line and each number within each row separated by spaces.

Returns a tuple `(draws, boards)` with `draws` a one-dimensional integer array of the
numbers drawn in order, and boards a three dimensional integer array with first
dimension indexing over the different boards in the order the appear in `input`, and
second and third dimensions over the rows and columns within each board.
"""
function readbingodata(input::IO)
    # First line of input is comma-delimited integers corresponding to drawn numbers
    draws = [parse(Int, draw) for draw in split(readuntil(input, "\n\n"), ',')]
    boardstrings = []
    while !eof(input)
        push!(boardstrings, readuntil(input, "\n\n"))
    end
    boards = Array{Int}(undef, length(boardstrings), 5, 5)
    for (i, boardstring) in enumerate(boardstrings)
        boards[i, :, :] = reduce(
            vcat,
            [parse(Int, numstring) for numstring in split(boardline)]'
            for boardline in split(boardstring, '\n')
        )
    end
    draws, boards
end

"""
    $(FUNCTIONNAME)(marks)

Computes which of bingo boards with marked entries indicated by `marks` are winners.

The bit array `marks` is assumed to be of shape `(numboards, 5, 5)` with the first
dimension indexing over different bingo boards and the second and third dimensions the
rows and columns of each board. A board is defined as a winner if all entries in a
row or column are marked, that is the correspond entries in `marks` are set to 1.

A bit array is returned of length `numboards` with entries set to 1 if the board at the
corresponding index is a winner.
"""
function getbingowinners(marks::BitArray{3})
    (any(all(marks, dims=2), dims=3) .| any(all(marks, dims=3), dims=2))[:, 1, 1]
end

function solve(info::Part1PuzzleInfo)
    draws, boards = open(readbingodata, info.datapath)
    marks = falses(size(boards))
    for draw in draws
        marks[boards .== draw] .= true
        winners = getbingowinners(marks)
        if any(winners)
            @assert sum(winners) == 1 "Multiple simultaneous winners."
            winningboard = dropdims(boards[winners, :, :]; dims=1)
            winningmarks = dropdims(marks[winners, :, :]; dims=1)
            return sum(winningboard[.!winningmarks]) * draw
        end
    end
end

function solve(info::Part2PuzzleInfo)
    draws, boards = open(readbingodata, info.datapath)
    marks = falses(size(boards))
    local lasttowinindex
    for draw in draws
        marks[boards .== draw] .= true
        winners = getbingowinners(marks)
        if sum(winners) == size(boards, 1) - 1
            lasttowinindex = findfirst(.!winners)
        elseif all(winners)
            lasttowinboard = boards[lasttowinindex, :, :]
            lasttowinmarks = marks[lasttowinindex, :, :]
            return sum(lasttowinboard[.!lasttowinmarks]) * draw
        end
    end
end

@testset "Day04" begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day04.txt"))) == 4512
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day04.txt"))) == 1924
end

end # module