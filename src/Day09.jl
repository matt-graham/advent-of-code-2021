module Day09

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day09PuzzleInfo <: PuzzleInfo end

"""
Day 9 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day09PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 9 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day09PuzzleInfo
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

"""
    $(FUNCTIONNAME)(index, shape)

Get iterator over valid offset indices at index `index` for 2D array with size `shape`.
"""
function offsetsat(index::CartesianIndex{2}, shape::Tuple{Integer, Integer})
    i_offsets(i) = i == 1 ? (1,) : (i == shape[1] ? (-1,) : (-1, 1))
    j_offsets(j) = j == 1 ? (1,) : (j == shape[2] ? (-1,) : (-1, 1))
    Iterators.flatten((
        (CartesianIndex(i, 0) for i in i_offsets(index[1])),
        (CartesianIndex(0, j) for j in j_offsets(index[2]))
    ))
end

"""
    $(FUNCTIONNAME)(heightmap)

Get bitarray of same size as `heightmap` indicating lowpoints.
"""
function getlowpoints(heightmap::AbstractArray{T, 2}) where T
    islowpoint = trues(size(heightmap))
    for index in CartesianIndices(heightmap)
        for offset in offsetsat(index, size(heightmap))
            islowpoint[index] &= heightmap[index] < heightmap[index + offset]
        end
    end
    islowpoint
end

"""
    $(FUNCTIONNAME)(visited, index, heightmap)

Recursively visit points in basin of `heightmap` from `index` recording in `visited`.
"""
function expandbasin!(
    visited::BitArray{2},
    index::CartesianIndex{2},
    heightmap::AbstractArray{T, 2}
) where T
    visited[index] = true
    for offset in offsetsat(index, size(heightmap))
        if heightmap[index + offset] < 9 && !visited[index + offset]
            expandbasin!(visited, index + offset, heightmap)
        end
    end
end

function solve(info::Part1PuzzleInfo)
    heightmap = open(readheightmap, info.datapath)
    islowpoint = getlowpoints(heightmap)
    sum(heightmap[islowpoint] .+ 1)
end

function solve(info::Part2PuzzleInfo)
    heightmap = open(readheightmap, info.datapath)
    islowpoint = getlowpoints(heightmap)
    basinsizes = Array{Int}(undef, count(islowpoint))
    for (i, lowpointindex) in enumerate(findall(islowpoint))
        visited = falses(size(islowpoint))
        expandbasin!(visited, lowpointindex, heightmap)
        basinsizes[i] = count(visited)
    end
    prod(partialsort(basinsizes, 1:3; rev=true))
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day09.txt"))) == 15
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day09.txt"))) == 1134
end

end # module