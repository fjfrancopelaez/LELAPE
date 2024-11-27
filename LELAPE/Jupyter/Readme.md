# About the version of Julia

Notebooks in the subfolders have been tested with Julia 1.7.2. Perhaps you have on your computer a different version, so we recommend you to open the __.pynb__ files with a simple text editor, to scroll down to the end of the file, and spot the _metadata_ section. There, you will find this:

    "metadata": {
        "kernelspec": {
            "display_name": "Julia 1.7.2", <-- HERE
            "language": "julia",
            "name": "julia-1.7.2" <-- HERE
            },
        "language_info": {
            "file_extension": ".jl",
            "mimetype": "application/julia",
            "name": "julia",
            "version": "1.7.2"  <-- AND HERE
            }
    },
    "nbformat": 4,
    "nbformat_minor": 4
    

Just replace __"1.7.2"__ by the version number you wish, save the file, close and open the notebook on the browser.
---------------------------
Alternatively, you can just open the Julia terminal (REPL) and type:

> `using Pkg`

> `Pkg.build("IJulia")`

> `using IJulia`

> `notebook()`

The new kernel is then added to Jupyter. You only need to open the __.pynb__ file and choose the kernel you wish.
