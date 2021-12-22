module Day16

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day16PuzzleInfo <: PuzzleInfo end

"""
Day 16 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day16PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 16 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day16PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(input)

Read Buoyancy Interchange Transmission System (BITS) packets from input stream `input`.
"""
function readbitspackets(input::IO)
    hexadecimalstring = readline(input)
    bytes = hex2bytes(hexadecimalstring)
    BitVector(reduce(vcat, reverse(b) for b in digits.(bytes, base=2, pad=8)))
end

"""
    $(FUNCTIONNAME)(bits)

Get the integer value correspond to a bit vector `bits` with most significant bit first.
"""
function bits2int(bits)
    powerof2 = 1
    intval = 0
    for b in Iterators.reverse(bits)
        intval += b * powerof2
        powerof2 <<= 1
    end
    intval
end

"""Buoyancy Interchange Transmission System (BITS) packet."""
abstract type Packet end

"""
Buoyancy Interchange Transmission System (BITS) literal packet.

$(FIELDS)
"""
struct LiteralPacket <: Packet
    """Version number for packet."""
    version::Int
    """Value of packet."""
    value::Int
end

"""
Buoyancy Interchange Transmission System (BITS) operator packet.

$(FIELDS)
"""
struct OperatorPacket <:Packet
    """Version number for packet."""
    version::Int
    """Type ID for packet."""
    typeid::Int
    """Subpackets of packet."""
    subpackets::Vector{Packet}
end

OperatorPacket(version, operator) = OperatorPacket(version, operator, [])

"""Map from operator packet type IDs to corresponding operators."""
const operatormap = Dict{Int, Function}(
    0 => sum,
    1 => prod,
    2 => minimum,
    3 => maximum,
    5 => x -> (x[1] > x[2]),
    6 => x -> (x[1] < x[2]),
    7 => x -> (x[1] == x[2])
)

"""
    $(FUNCTIONNAME)(bits)

Process packet represented by leading elements BITS transmission `bits`. Returns
tuple consisting of packet and remaining elements of `bits` after packet bits removed.
"""
function processpacket(bits)
    version, bits = bits2int(bits[1:3]), bits[4:end]
    typeid, bits = bits2int(bits[1:3]), bits[4:end]
    if typeid == 4
        literalbits = BitVector()
        while bits[1] != 0
            append!(literalbits, bits[2:5])
            bits = bits[6:end]
        end
        append!(literalbits, bits[2:5])
        packet = LiteralPacket(version, bits2int(literalbits))
        bits = bits[6:end]
    else
        packet = OperatorPacket(version, typeid)
        if bits[1] == 0
            subpacketslength, bits = bits2int(bits[2:16]), bits[17:end]
            subpacketbits, bits = bits[1:subpacketslength], bits[subpacketslength+1:end]
            while !isempty(subpacketbits)
                subpacket, subpacketbits = processpacket(subpacketbits)
                push!(packet.subpackets, subpacket)
            end
        else
            subpacketsnumber, bits = bits2int(bits[2:12]), bits[13:end]
            for p in 1:subpacketsnumber
                subpacket, bits = processpacket(bits)
                push!(packet.subpackets, subpacket)
            end
        end
    end
    packet, bits
end

"""
    $(FUNCTIONNAME)(packet)

Evaluate the value represented by `packet`.
"""
function getvalue(::Packet) end

getvalue(packet::LiteralPacket) = packet.value

function getvalue(packet::OperatorPacket)
    operatormap[packet.typeid]([getvalue(subpacket) for subpacket in packet.subpackets])
end

"""
    $(FUNCTIONNAME)(packet)

Recursively compute sum of version of `packet` and all subpackets.
"""
function getversionsum(packet::Packet)
    if isa(packet, OperatorPacket)
        packet.version + sum(getversionsum(subpacket) for subpacket in packet.subpackets)
    else
        packet.version
    end
end

function solve(info::Day16PuzzleInfo)
    bits = open(readbitspackets, info.datapath)
    packet, bits = processpacket(bits)
    @assert !any(bits) "Expected remaining bits to all be zero"
    isa(info, Part1PuzzleInfo) ? getversionsum(packet) : getvalue(packet)
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-1.txt"))) == 16
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-2.txt"))) == 12
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-3.txt"))) == 23
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-4.txt"))) == 31
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-5.txt"))) == 3
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-6.txt"))) == 54
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-7.txt"))) == 7
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-8.txt"))) == 9
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-9.txt"))) == 1
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-10.txt"))) == 0
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-11.txt"))) == 0
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day16-12.txt"))) == 1
end

end # module