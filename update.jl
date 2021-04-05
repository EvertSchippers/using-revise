function get_depot_file_path(rel_path...)
    depot = first(DEPOT_PATH)
    return joinpath(depot, rel_path...)
end

function copy_to_depot(rel_path)
    depot = first(DEPOT_PATH)
    here = dirname(@__FILE__())
    if !isdir(dirname(joinpath(depot, rel_path)))
        mkpath(dirname(joinpath(depot, rel_path)))
    end
    cp(joinpath(here, rel_path), joinpath(depot, rel_path), force=true)
end

function inject(original_lines, new_lines, wrapper_line)
    
    tag_locations = findall(startswith(wrapper_line), original_lines)

    if length(tag_locations) == 0
        # no wrappers in there yet, let's pretent they're after the end of the file.
        push!(tag_locations, length(original_lines) + 1)
        push!(tag_locations, length(original_lines) + 2)
    end

    if length(tag_locations) != 2
        error("Hmmm... something fishy going on, couldn't find exactly 2 wrapper lines...")
    end

    keep_before = 1:length(original_lines) .< minimum(tag_locations)
    keep_after = 1:length(original_lines) .> maximum(tag_locations)

    new_content = vcat(original_lines[keep_before], 
                        wrapper_line * " (START)",
                        new_lines,
                        wrapper_line * " (END)",
                        original_lines[keep_after])

    return new_content

end

function update_startup()
    startup_file = get_depot_file_path("config", "startup.jl")
    inject_startup_content = readlines(joinpath("config", "startup.jl"))
    wrapper = "### INSERTED BY `using-revise` ###"
    new_startup_content = inject(readlines(startup_file), inject_startup_content, wrapper)
end

function copy_scripts()

    for script_file in readdir("scripts")
        copy_to_depot(joinpath("scripts", script_file))
    end

end

function run_some_tests()

    @info "Running some tests, just to be sure..."

    original_empty = ["A", "B", "C"]
    to_inject = ["D", "E", "F"]
    expected = ["A", "B", "C", "tag (START)", "D", "E", "F", "tag (END)"]

    if !(inject(original_empty, to_inject, "tag") == expected)
        error("Stuff's broken... Better not use this!")
    end

    original_with_single_tag = ["A", "B", "tag", "C"]
    errored = false

    try
        inject(original_with_single_tag, to_inject, "tag") 
    catch
        errored = true
    end

    if (!errored)
        error("Stuff's broken... Better not use this!")
    end

    original_with_tags = ["A", "B", "tag whatever", "C", "tag 42", "XYZ"]
    expected = ["A", "B", "tag (START)", "D", "E", "F", "tag (END)", "XYZ"]

    if !(inject(original_with_tags, to_inject, "tag") == expected)
        error("Stuff's broken... Better not use this!")
    end

    @info "All good! Let's do this!"

end

run_some_tests()


@info "Rewritten your startup!"