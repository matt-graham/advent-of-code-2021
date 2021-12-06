module Day06

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

"""
Day 6  puzzle information.

$(FIELDS)
"""
struct Day06PuzzleInfo <: PuzzleInfo
    """Path to input data file."""
    datapath::String
    """Number of days to simulate."""
    numdays::Int
end

"""
    $(FUNCTIONNAME)(agecounts)

Update dictionary of age counts `agecounts` according to lanternfish growth model.

`agecounts` maps (integer) age in days to number of fish of that age.
"""
function updateagecounts!(agecounts::Dict{S, T}) where {S <: Integer, T <: Integer}
    zerocount = agecounts[0]
    for age in 1:8
        agecounts[age - 1] = agecounts[age]
    end
    agecounts[8] = zerocount
    agecounts[6] += zerocount
end

function solve(info::Day06PuzzleInfo)
    agecounts = Dict{Int, BigInt}(age => 0 for age in 0:8)
    open(info.datapath) do input
        for agestring in split(readline(input), ',')
            agecounts[parse(Int, agestring)] += 1
        end
    end
    for day in 1:info.numdays
        updateagecounts!(agecounts)
    end
    return sum(values(agecounts))
end

@testset begin
    @test solve(Day06PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day06.txt"), 80)) == 5934
    @test solve(Day06PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day06.txt"), 256)) == 26984457539
end

end # module