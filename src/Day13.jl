module Day13

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day13PuzzleInfo <: PuzzleInfo end

"""
Day 13 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day13PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 13 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day13PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(input)

Read fold instructions from input stream `input`.
"""
function readfoldinstructions(input::IO)
    dotindices = [
        CartesianIndex(map(s -> parse(Int, s), split(pairstring, ','))...)
        for pairstring in split(readuntil(input, "\n\n"), '\n')
    ]
    function parsefoldinstruction(foldinstruction)
        instruction, coordinate = split(foldinstruction, '=')
        (instruction[end], parse(Int, coordinate))
    end
    folds = map(parsefoldinstruction, readlines(input))
    dotindices, folds
end

"""
    $(FUNCTIONNAME)(dotindices)

Get bit matrix with true values corresponding to indexes in `dotindices` minus an index
offset `offset`.
"""
function getdotsandoffset(dotindices::Vector{CartesianIndex{2}})
    min_x = minimum(p -> p[1], dotindices)
    max_x = maximum(p -> p[1], dotindices)
    min_y = minimum(p -> p[2], dotindices)
    max_y = maximum(p -> p[2], dotindices)
    dots = falses(
        max_x - min_x + (isodd(max_x - min_x) ? 2 : 1),
        max_y - min_y + (isodd(max_y - min_y) ? 2 : 1)
    )
    offset = CartesianIndex(min_x - 1, min_y - 1)
    for index in dotindices
        dots[index - offset] = true
    end
    dots, offset
end

"""
    $(FUNCTIONNAME)(dots)

Convert bit matrix `dots` to a corresponding Unicode 'block' string.
"""
function dotstostring(dots::BitMatrix)
    join(
        (join(dots[i, j] ? '█' : ' ' for i in 1:size(dots, 1)) for j in 1:size(dots, 2)),
        '\n'
    )
end

function solve(info::Day13PuzzleInfo)
    dotindices, folds = open(readfoldinstructions, info.datapath)
    dots, offset = getdotsandoffset(dotindices)
    for (axis, coordinate) in folds[1:(isa(info, Part1PuzzleInfo) ? 1 : end)]
        if axis == 'x'
            leftdots = dots[1:coordinate-offset[1]-1, :]
            rightdots = dots[end:-1:coordinate-offset[1]+1, :]
            dots = leftdots .| rightdots
        else
            topdots = dots[:, 1:coordinate-offset[2]-1]
            bottomdots = dots[:, end:-1:coordinate-offset[2]+1]
            dots = topdots .| bottomdots
        end
    end
    if isa(info, Part1PuzzleInfo)
        count(dots)
    else
        print(dotstostring(dots))
        dots
    end
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day13.txt"))) == 17
end

end # module