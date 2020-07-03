import Pkg

struct __FoundNothing end;
function include(::Type{__FoundNothing}) end

function findscript(jlfile)

    hasextension = length((splitext(jlfile))[2]) > 0
    rel_path = joinpath("scripts", jlfile)

    depots = Pkg.depots()
    for depot in depots
        abs_path = joinpath(depot, rel_path)
        
        if isfile(abs_path)
            return abs_path
        end

        if !hasextension
            abs_path = abs_path * ".jl"

            if isfile(abs_path)
                return abs_path
            end
        end 
    end
    
    return __FoundNothing
end

function activate_dev()
    include(findscript("develop"))
end