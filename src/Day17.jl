module Day17

using ..ReTest, ..DocStringExtensions

import ..solve, ..PuzzleInfo, ..TEST_DATA_DIRECTORY

abstract type Day17PuzzleInfo <: PuzzleInfo end

"""
Day 17 part 1 puzzle information.

$(FIELDS)
"""
struct Part1PuzzleInfo <: Day17PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
Day 17 part 2 puzzle information.

$(FIELDS)
"""
struct Part2PuzzleInfo <: Day17PuzzleInfo
    """Path to input data file."""
    datapath::String
end

"""
    $(FUNCTIONNAME)(input)

Read target area limits from input stream `input`.
"""
function readtargetarealimits(input::IO)
    targetareastring = readline(input)
    @assert targetareastring[1:13] == "target area: "
    xlimitstring, ylimitstring = split(targetareastring[14:end], ", ")
    @assert xlimitstring[1:2] == "x="
    @assert ylimitstring[1:2] == "y="
    xlimits = [parse(Int, lim) for lim in split(xlimitstring[3:end], "..")]
    ylimits = [parse(Int, lim) for lim in split(ylimitstring[3:end], "..")]
    xlimits, ylimits
end


"""
    $(FUNCTIONNAME)(xlimits, ylimits, initialvelocity)

Whether probe launched with `initialvelocity` will enter target area with horizontal
limits `xlimits` and vertical limits `ylimits` in any step.
"""
function hitstargetarea(xlimits, ylimits, initialvelocity)
    pos = [0, 0]
    velocity = copy(initialvelocity)
    while pos[1] <= xlimits[2] && pos[2] >= ylimits[1]
        if xlimits[1] <= pos[1] <= xlimits[2] && ylimits[1] <= pos[2] <= ylimits[2]
            return true
        end
        pos += velocity
        velocity[1] = max(0, velocity[1] - 1)
        velocity[2] -= 1
    end
    false
end

function solve(info::Day17PuzzleInfo)
    xlimits, ylimits = open(readtargetarealimits, info.datapath)
    ypos(velocity, nstep) = nstep * velocity - (nstep * (nstep - 1) ÷ 2)
    if isa(info, Part1PuzzleInfo)
        if ylimits[1] > 0
            ypos(ylimits[1], ylimit[1])d
        elseif ylimits[1] < 0
            ypos(-ylimits[1] - 1, -ylimits[1] - 1)
        else
            error("Target area lower boundary allows infinite velocity")
        end
    else
        numvel = 0
        # Lower bound on x-velocity corresponds to just hitting left limit of target
        # area as x-velocity reaches 0: vx * (vx + 1) ÷ 2 >= xlimits[1] for integer vx
        # Upper bound on x-velocity correspondings to hitting right limit of target area
        # in one step
        for vx in ceil(Int, (sqrt(1 + 8 * xlimits[1]) - 1) / 2):xlimits[2]
            # Lower bound on y-velocity corresponds to hitting lower limit in one step
            # Upper bound on y-velocity corresponds to hitting lower limit in
            # (2 * vy + 1) steps
            for vy in ylimits[1]:(-ylimits[1] - 1)
                hitstargetarea(xlimits, ylimits, [vx, vy]) && (numvel += 1)
            end
        end
        numvel
    end
end

@testset begin
    @test solve(Part1PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day17.txt"))) == 45
    @test solve(Part2PuzzleInfo(joinpath(TEST_DATA_DIRECTORY, "day17.txt"))) == 112
end

end # module