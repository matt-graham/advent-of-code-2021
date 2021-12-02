using Documenter, AoC2021

for symbol in names(AoC2021; all=true)
    object = eval(:(AoC2021.$symbol))
    if isa(object, Module) && object != AoC2021
        qualifiedname = string(object)
        name = split(qualifiedname, '.')[2]
        content = """
        # $qualifiedname

        ```@index
        Modules = [$qualifiedname]
        Order = [:function, :type]
        ```

        ```@autodocs
        Modules = [$qualifiedname]
        Order = [:function, :type]
        ```
        """
        open(joinpath(@__DIR__, "src", lowercase(name) * ".md"), "w") do file
            write(file, content)
        end
    end
end

makedocs(
    sitename = "Advent of Code 2021",
    modules = [AoC2021],
    strict = true
)
