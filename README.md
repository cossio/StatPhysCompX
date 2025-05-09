# Computational resources for Statistical Physics course at École Polytechnique

This repository contains computational resources for the Statistical Physics course at École Polytechnique, imparted by Rémi Monasson. Some are external links to resources found on the web illustrating concepts covered in the course, while others are original codes written by authors of this repository. The original codes are written in Julia (https://julialang.org).

For any questions or suggestions, please contact the author of this repository: [Jorge FERNANDEZ-DE-COSSIO-DIAZ](https://sites.google.com/view/jorgefdcd). Also feel free to open an issue in the repository or a send a pull request if you have any suggestions or improvements.

Codes in Julia:

- Simulations of the 2D Ising model, with Metropolis and Wolff algorithms: https://github.com/cossio/IsingModels.jl. 
- Conserved order-parameter Ising model with the Kawasaki algorithm: https://github.com/cossio/PHY433.jl/blob/main/pluto/COP.jl. This is a Pluto notebook.

## Setting up Julia

The recommended way to install [Julia](https://julialang.org) is to use the Juliaup installer. 

On Unix-type system open a terminal and run the following command:

```bash
curl -fsSL https://install.julialang.org | sh
```

and follow the instructions.

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