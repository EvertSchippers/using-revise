struct __FoundNothing end;

function include(::Type{__FoundNothing}) end

"""
    include_script(jlfile)

`include`s a scripts, located in your ~/.julia/scripts folder. You may omit the `.jl` extension of the file.
Does nothing (no error) when the file does not exist.
"""
function include_script(jlfile)
    include(find_in_depot(joinpath("scripts", jlfile)))
end

"""
    find_in_depot(rel_path)

Returns the absolute path of a file in your julia depot. It will look the root and the /scripts folder, and in case of no file extension, tries to find a file with the .jl extension.
"""
function find_in_depot(rel_path)

    hasextension = length((splitext(rel_path))[2]) > 0
    hasdir = length(dirname(rel_path)) > 0

    for depot in DEPOT_PATH

        abs_path = joinpath(depot, rel_path)
        try_these = [abs_path]
        
        if !hasextension
            push!(try_these, abs_path * ".jl")
        end

        if !hasdir
            for file in copy(try_these)
                push!(try_these, joinpath( dirname(file), "scripts", basename(file) ))
            end
        end

        for file in try_these
            if isfile(file)
                return file
            end
        end
    end
    
    @warn "Script '$(rel_path)' not found."
    return __FoundNothing
end

activate_dev() = include_script("develop")
runtests() = include("runtests.jl")