module Day05

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day05PuzzleInfo <: PuzzleInfo end

"""
Day 5 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day05PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 5 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day05PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Line segment joining two points in two-dimensional spatial domain.

$(FIELDS)
"""
struct LineSegment{T}
    """x-coordinate of first point."""
    x1::T
    """y-coordinate of first point."""
    y1::T
    """x-coordinate of second point."""
    x2::T
    """y-coordinate of second point."""
    y2::T
end

"""
    $(FUNCTIONNAME)(linesegmentstring)

Construct a `LineSegment` object from a string specification `"x1,y1 -> x2,y2"`.
"""
function parselinesegmentstring(linesegmentstring::AbstractString)
    point1string, point2string = split(linesegmentstring, " -> ")
    x1, y1 = [parse(Int, num) for num in split(point1string, ',')]
    x2, y2 = [parse(Int, num) for num in split(point2string, ',')]
    LineSegment{Int}(x1, y1, x2, y2)
end


"""
    $(FUNCTIONNAME)(linefrequencies, min_x, min_y, segment, processdiagonals)

Increment indices in `linefrequencies` representing line segment `segment`.

The value `linefrequencies[i, j]` represents the number of lines covering the point with
coordinates `(min_x + i - 1, min_y + i - 1)`. If `processdiagonals` is `false` (the
default) only horizontal and vertical line segments are recorded, if `true` diagonal
line segments are also recorded.
"""
function addlinesegment!(
    linefrequencies::AbstractArray{S, 2},
    min_x::T,
    min_y::T,
    segment::LineSegment{T},
    processdiagonals::Bool=false
) where {S<:Integer, T<:Integer}
    if segment.x1 == segment.x2 || segment.y1 == segment.y2
        linefrequencies[
            (min(segment.x1, segment.x2) - min_x + 1):(
                max(segment.x1, segment.x2) - min_x + 1),
            (min(segment.y1, segment.y2) - min_y + 1):(
                max(segment.y1, segment.y2) - min_y + 1)
        ] .+= 1
    elseif processdiagonals
        @assert abs(segment.x2 - segment.x1) == abs(segment.y2 - segment.y1)
        for i in 0:abs(segment.x2 - segment.x1)
            linefrequencies[
                segment.x1 + sign(segment.x2 - segment.x1) * i - min_x + 1,
                segment.y1 + sign(segment.y2 - segment.y1) * i - min_x + 1,
            ] += 1
        end
    end
end

function solve(info::Day05PuzzleInfo)
    linesegments = open(info.datapath, "r") do input
        [parselinesegmentstring(segmentstring) for segmentstring in eachline(input)]
    end
    min_x = minimum(l -> min(l.x1, l.x2), linesegments)
    max_x = maximum(l -> max(l.x1, l.x2), linesegments)
    min_y = minimum(l -> min(l.y1, l.y2), linesegments)
    max_y = maximum(l -> max(l.y1, l.y2), linesegments)
    linefrequencies = zeros(Int, max_x - min_x + 1, max_y - min_y + 1)
    for linesegment in linesegments
        addlinesegment!(
            linefrequencies, min_x, min_y, linesegment, isa(info, Part2PuzzleInfo)
        )
    end
    return sum(linefrequencies .>= 2)
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day05.txt"))) == 5
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day05.txt"))) == 12
end

end # module