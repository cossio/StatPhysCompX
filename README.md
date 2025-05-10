# Computational resources for Statistical Physics course at École Polytechnique

This repository contains computational resources for the Statistical Physics course at École Polytechnique, imparted by Rémi Monasson. Some are external links to resources found on the web illustrating concepts covered in the course, while others are original codes written by authors of this repository. Some original codes are written in Julia (https://julialang.org) and others in Python.

For any questions or suggestions, please contact the author of this repository: [Jorge FERNANDEZ-DE-COSSIO-DIAZ](https://sites.google.com/view/jorgefdcd). Also feel free to open an issue in the repository or a send a pull request if you have any suggestions for improvements.

## Setting up Julia

The recommended way to install [Julia](https://julialang.org) is to use the `juliaup` installer. On Unix-type system (Linux, macOS) open a terminal and run the following command:

```bash
curl -fsSL https://install.julialang.org | sh
```

and follow the instructions (you can accept the default settings). If you are using Windows instead, open the command prompt and run the following command:

```bash
winget install --name Julia --id 9NJNWW8PVKMN -e -s msstore
```

This will install the latest version of Julia on your system. Now to open Julia, you can run the following command in the terminal:

```bash
julia
```

Note that right after installing Julia, you may need to close and reopen the terminal for the `julia` command to be recognized. This will open the Julia REPL (Read-Eval-Print Loop), which is an interactive shell for Julia. You can run Julia commands directly in the REPL.

We also use [Pluto](https://plutojl.org) notebooks, which are a Julia package that allows you to create interactive notebooks. To install Pluto, open Julia and run the following command:

```julia
import Pkg
Pkg.add("Pluto")
```

To run a Pluto notebook, open Julia and run the following command:

```julia
using Pluto
Pluto.run()
```

This will open a web browser with the Pluto interface. You can create a new notebook by clicking on the "New notebook" button. You can also open an existing notebook by clicking on the "Open notebook" button and selecting the notebook file.

# Contents

Codes in Julia:

- Simulations of the 2D Ising model, with Metropolis and Wolff algorithms: https://github.com/cossio/IsingModels.jl. 
- Conserved order-parameter Ising model with the Kawasaki algorithm: https://github.com/cossio/PHY433.jl/blob/main/pluto/COP.jl. This is a Pluto notebook.
