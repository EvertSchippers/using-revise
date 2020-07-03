# Quick README #

The combination of this `startup.jl` and the `develop.jl` script will allow you to "virtually" add Revise to your project (without actually touching your Project or Manifest), and using it to quickly develop and run tests.

## Usage ##
#### startup.jl ####
Append-to or replace your `~/.julia/config/startup.jl` with the one from this repo.
#### develop.jl ####
Make the folder `~/.julia/scripts/` and place `develop.jl` in it.
#### From now on... ####
Start julia in the project/environment folder you're developing, or activate it, so typically run `julia --project=.`, if your terminal is already there.

Then, first thing, run `activate_dev()`. It makes a new test environment in your temp folder and activates it. 
It will be based upon the current Manifest and Project, but will add Revise and the [test] dependencies as well.
Also, it will call `using Revise` for you and move the current dir to the `test` folder in your project.

Now, you can directly call `include("runtests.jl")` rather than `Pkg] test YourPackage` - the latter will need to recompile the lot from scratch every time, but the former will, thanks to Revise, only recompile the bits that changed! Your tests will run WAY faster (the second+ time you run them) and
still will truly test you latests changes!

Now you can develop FAST! And temporarily and quickly uncomment/comment bits and pieces in your `runtests.jl` while you're still in the hacking stage!