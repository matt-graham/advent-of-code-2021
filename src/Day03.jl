module Day03

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day03PuzzleInfo <: PuzzleInfo end

"""
Day 3 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day03PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 3 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day03PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(input)

Get number of characters in first line of input stream `input`.
"""
function getfirstlinelength(input::IO)
    firstline = readline(input)
    length(firstline)
end

"""
    $(FUNCTIONNAME)(bitvector)

Convert binary representation of integer `bitvector` to corresponding (decimal) integer.
"""
function bitvectortodecimal(bitvector::BitVector)
    sum(2^(i-1) for (i, bit) in enumerate(reverse(bitvector)) if bit)
end

"""
    $(FUNCTIONNAME)(input)

Read 2D bit array from input stream `input` with (equi-length) string of bits per line.
"""
function readbitarray(input::IO)
    reduce(vcat, (BitArray(parse(UInt8, b) for b in l)' for l in eachline(input)))
end

function solve(info::Part1PuzzleInfo)
    bitarray = open(readbitarray, info.datapath)
    counts = vec(sum(bitarray, dims=1))
    numline = size(bitarray, 1)
    @assert all(counts .!= (numline / 2)) "Equal number of one and zero bits"
    moreones = counts .>= (numline / 2)
    gammarate = bitvectortodecimal(moreones)
    epsilonrate = bitvectortodecimal(.!moreones)
    gammarate * epsilonrate
end

function filterbycriteriaoncolumn(criteria, bitarray::BitArray, column::Integer)
    bitarray[criteria(bitarray[:, column]), :]
end

function oxygengenerator_bitcriteria(bitvector::BitVector)
    bitvector .== (sum(bitvector) .>= size(bitvector, 1) / 2)
end

function co2scrubber_bitcriteria(bitvector::BitVector)
    bitvector .== (sum(bitvector) .< size(bitvector, 1) / 2)
end

function solve(info::Part2PuzzleInfo)
    bitarray = open(readbitarray, info.datapath)
    oxygenbitarray, co2bitarray = bitarray, bitarray
    for column in 1:size(bitarray, 2)
        if size(oxygenbitarray, 1) != 1
            oxygenbitarray = filterbycriteriaoncolumn(
                oxygengenerator_bitcriteria, oxygenbitarray, column
            )
        end
        if size(co2bitarray, 1) != 1
            co2bitarray = filterbycriteriaoncolumn(
                co2scrubber_bitcriteria, co2bitarray, column
            )
        end
        size(oxygenbitarray, 1) == 1 && size(co2bitarray, 1) == 1 && break
    end
    oxygengeneratorrate = bitvectortodecimal(oxygenbitarray[1, :])
    co2scrubberrate = bitvectortodecimal(co2bitarray[1, :])
    oxygengeneratorrate * co2scrubberrate
end

@testset "Day03" begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day03.txt"))) == 198
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day03.txt"))) == 230
end

end # module