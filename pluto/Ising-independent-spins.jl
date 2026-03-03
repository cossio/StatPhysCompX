### A Pluto.jl notebook ###
# v0.20.8

using Markdown
using InteractiveUtils

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000001
using Statistics: mean, std

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000002
using Random: randexp

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000003
using ProgressLogging: @progress

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000004
import Makie, CairoMakie

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000010
md"""
# Monte Carlo sampling of independent spins

This notebook is part of the computational resources for the Statistical Physics course at École Polytechnique. To return to the main repository, follow this link: [https://github.com/cossio/StatPhysCompX](https://github.com/cossio/StatPhysCompX).
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000011
md"""
In this notebook, we introduce the **Metropolis algorithm** on a very simple model: $N$ independent Ising spins in an external field. Because the spins do not interact with each other, we can compute all thermodynamic quantities analytically, and verify that the Monte Carlo simulation gives the correct results.

## The model

We consider $N$ spins $\sigma_i \in \{-1, +1\}$, subject to a uniform external field $h$. The energy of a configuration $\boldsymbol{\sigma} = (\sigma_1, \ldots, \sigma_N)$ is:

```math
E(\boldsymbol{\sigma}) = -h \sum_{i=1}^{N} \sigma_i
```

Note that there is no interaction between spins (no $\sigma_i \sigma_j$ terms). Each spin simply prefers to align with the external field $h$.

At inverse temperature $\beta$, the Boltzmann distribution is:

```math
P(\boldsymbol{\sigma}) = \frac{1}{Z} e^{-\beta E(\boldsymbol{\sigma})} = \frac{1}{Z} e^{\beta h \sum_i \sigma_i}
```

Since the spins are independent, this factorizes:

```math
P(\boldsymbol{\sigma}) = \prod_{i=1}^{N} P(\sigma_i), \qquad P(\sigma_i) = \frac{e^{\beta h \sigma_i}}{2\cosh(\beta h)}
```

We can absorb $\beta$ into $h$ by redefining $h \to \beta h$, so in what follows $h$ plays the role of $\beta h$ (i.e., we set $\beta = 1$).
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000012
md"""
## Analytical results

Because the spins are independent, exact results are easy to derive.

The **average magnetization per spin** is:

```math
m = \langle \sigma_i \rangle = \frac{e^{h} - e^{-h}}{e^{h} + e^{-h}} = \tanh(h)
```

The **variance** of a single spin is:

```math
\text{Var}(\sigma_i) = 1 - \tanh^2(h) = \operatorname{sech}^2(h)
```

The **average energy per spin** is:

```math
\frac{\langle E \rangle}{N} = -h \tanh(h)
```

These formulas let us verify that our Metropolis simulation works correctly.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000013
md"""
## The Metropolis algorithm

The Metropolis algorithm generates samples from the Boltzmann distribution $P(\boldsymbol{\sigma}) \propto e^{-E(\boldsymbol{\sigma})}$ by performing local updates. At each step:

1. Pick a random spin $i$.
2. Compute the energy change $\Delta E$ that would result from flipping $\sigma_i \to -\sigma_i$.
3. Accept the flip with probability $\min(1, e^{-\Delta E})$.

For our model, flipping $\sigma_i \to -\sigma_i$ gives:

```math
\Delta E = -h(-\sigma_i) - (-h\sigma_i) = 2h\sigma_i
```

so the flip is always accepted when $h\sigma_i < 0$ (the spin aligns with the field), and accepted with probability $e^{-2h\sigma_i}$ otherwise.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000020
function metropolis(; h::Real, N::Int, steps_between_frames::Int, number_of_frames::Int)
	σ = bitrand(N)
	mag = zeros(number_of_frames)
	mag[1] = (2sum(σ) - N) / N
	@progress for f = 2:number_of_frames
		for _ = 1:steps_between_frames
			i = rand(1:N)
			s = 2σ[i] - 1  # convert Bool to ±1
			ΔE = 2h * s
			if ΔE ≤ 0 || randexp() ≥ ΔE
				σ[i] = !σ[i]
			end
		end
		mag[f] = (2sum(σ) - N) / N
	end
	return mag
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000021
using Random: bitrand

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000030
md"""
## Magnetization trace

Let us first run the simulation for a few values of the external field $h$ and observe how the magnetization per spin evolves over time. We expect the system to quickly equilibrate to a value close to $\tanh(h)$.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000031
N_trace = 100

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000032
values_of_h_trace = [0.0, 0.2, 0.5, 1.0]

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000033
traces = map(values_of_h_trace) do h
	@info "Simulating h=$h"
	metropolis(; h, N=N_trace, steps_between_frames=N_trace, number_of_frames=5000)
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000034
let fig = Makie.Figure()
	for (n, h) = enumerate(values_of_h_trace)
		ax = Makie.Axis(fig[n, 1]; title="h = $h", width=700, height=150, xlabel="time (sweeps)", ylabel="magnetization per spin")
		Makie.lines!(ax, 1:length(traces[n]), traces[n]; linewidth=0.5)
		Makie.hlines!(ax, [tanh(h)]; color=:red, linestyle=:dash, linewidth=1.5, label="tanh(h)")
		Makie.ylims!(ax, -1, 1)
		Makie.axislegend(ax; position=:rt)
	end
	Makie.resize_to_layout!(fig)
	fig
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000035
md"""
The magnetization fluctuates around the analytical value $\tanh(h)$ (red dashed line). For $h = 0$, the magnetization fluctuates symmetrically around zero. As $h$ increases, the spins prefer to align with the field, and the average magnetization increases towards $+1$.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000040
md"""
## Average magnetization vs. external field

We now sweep over many values of $h$ and compare the Monte Carlo estimate of the average magnetization to the exact result $m = \tanh(h)$.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000041
N_sweep = 100

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000042
values_of_h_sweep = range(-2, 2; length=21)

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000043
n_warmup = 500

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000044
sweep_results = map(values_of_h_sweep) do h
	@info "Simulating h=$h"
	mag = metropolis(; h, N=N_sweep, steps_between_frames=N_sweep, number_of_frames=10_000)
	(avg=mean(mag[n_warmup:end]), std=std(mag[n_warmup:end]))
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000045
let fig = Makie.Figure()
	ax = Makie.Axis(fig[1, 1]; xlabel="h", ylabel="m = ⟨σᵢ⟩", title="Magnetization vs. external field (N = $N_sweep)", width=500, height=400)
	h_fine = range(-2.5, 2.5; length=200)
	Makie.lines!(ax, h_fine, tanh.(h_fine); color=:black, linewidth=2, label="tanh(h) (exact)")
	mavg = [r.avg for r = sweep_results]
	mstd = [r.std for r = sweep_results]
	Makie.scatter!(ax, collect(values_of_h_sweep), mavg; color=:blue, markersize=8, label="Monte Carlo")
	Makie.errorbars!(ax, collect(values_of_h_sweep), mavg, mstd; color=:blue, whiskerwidth=5)
	Makie.axislegend(ax; position=:rb)
	Makie.resize_to_layout!(fig)
	fig
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000046
md"""
The Monte Carlo results agree with the exact $\tanh(h)$ curve. The error bars represent the standard deviation of the magnetization over the simulation, which reflects both thermal fluctuations and Monte Carlo noise.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000050
md"""
## Distribution of the magnetization

Since the spins are independent, the total magnetization $M = \sum_i \sigma_i$ is a sum of i.i.d. random variables. By the central limit theorem, for large $N$, the magnetization per spin $m = M/N$ is approximately Gaussian:

```math
m \approx \mathcal{N}\!\left(\tanh(h),\; \frac{\operatorname{sech}^2(h)}{N}\right)
```

Let us verify this by plotting histograms of the magnetization from our simulation.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000051
N_hist = 200

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000052
values_of_h_hist = [0.0, 0.3, 0.7, 1.5]

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000053
hist_traces = map(values_of_h_hist) do h
	@info "Simulating h=$h"
	metropolis(; h, N=N_hist, steps_between_frames=N_hist, number_of_frames=50_000)
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000054
import Distributions

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000055
let fig = Makie.Figure()
	for (n, h) = enumerate(values_of_h_hist)
		row, col = fldmod1(n, 2)
		ax = Makie.Axis(fig[row, col]; title="h = $h", width=350, height=250, xlabel="magnetization per spin", ylabel="density")
		data = hist_traces[n][500:end]  # discard warmup
		Makie.hist!(ax, data; bins=40, normalization=:pdf, color=(:steelblue, 0.7), label="MC histogram")
		# Overlay the Gaussian prediction
		μ = tanh(h)
		σ = sqrt(1 / (N_hist * cosh(h)^2))
		x = range(μ - 4σ, μ + 4σ; length=200)
		Makie.lines!(ax, x, [Distributions.pdf(Distributions.Normal(μ, σ), xi) for xi = x]; color=:red, linewidth=2, label="Gaussian (CLT)")
		Makie.vlines!(ax, [μ]; color=:red, linestyle=:dash, linewidth=1)
		Makie.axislegend(ax; position=:rt, labelsize=10)
	end
	Makie.resize_to_layout!(fig)
	fig
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000056
md"""
The histograms match the Gaussian prediction from the central limit theorem. Note that as $|h|$ increases, the variance decreases (the spins are more firmly aligned with the field, so there are fewer fluctuations).
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000060
md"""
## Effect of system size

As the number of spins $N$ increases, the fluctuations of the magnetization per spin decrease as $1/\sqrt{N}$. Let us verify this.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000061
h_fixed = 0.5

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000062
values_of_N = [10, 50, 200, 1000]

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000063
size_traces = map(values_of_N) do N
	@info "Simulating N=$N"
	metropolis(; h=h_fixed, N, steps_between_frames=N, number_of_frames=20_000)
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000064
let fig = Makie.Figure()
	for (n, N) = enumerate(values_of_N)
		ax = Makie.Axis(fig[n, 1]; title="N = $N", width=700, height=150, xlabel="time (sweeps)", ylabel="magnetization per spin")
		Makie.lines!(ax, 1:length(size_traces[n]), size_traces[n]; linewidth=0.5)
		Makie.hlines!(ax, [tanh(h_fixed)]; color=:red, linestyle=:dash, linewidth=1.5, label="tanh(h)")
		Makie.ylims!(ax, -1, 1)
		Makie.axislegend(ax; position=:rt)
	end
	Makie.resize_to_layout!(fig)
	fig
end

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000065
md"""
As expected, the fluctuations decrease with increasing $N$. With $N = 1000$ spins, the magnetization per spin is very close to $\tanh(h)$ at all times.
"""

# ╔═╡ a1b2c3d4-1111-4000-a000-000000000070
md"""
## Summary

In this notebook, we implemented the Metropolis algorithm for the simplest possible Ising model: independent spins in an external field. We verified that:

1. The average magnetization per spin converges to the exact value $m = \tanh(h)$.
2. The distribution of the magnetization is Gaussian, as predicted by the central limit theorem.
3. Fluctuations decrease as $1/\sqrt{N}$ with increasing system size.

This simple example illustrates the basic mechanics of the Metropolis algorithm before applying it to more complex models with interactions (see the Ising model notebook).
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
CairoMakie = "~0.13.4"
Distributions = "~0.25"
Makie = "~0.22.4"
ProgressLogging = "~0.1.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.5"
manifest_format = "2.0"
project_hash = "0000000000000000000000000000000000000000"
"""

# ╔═╡ Cell order:
# ╟─a1b2c3d4-1111-4000-a000-000000000010
# ╟─a1b2c3d4-1111-4000-a000-000000000011
# ╟─a1b2c3d4-1111-4000-a000-000000000012
# ╟─a1b2c3d4-1111-4000-a000-000000000013
# ╠═a1b2c3d4-1111-4000-a000-000000000001
# ╠═a1b2c3d4-1111-4000-a000-000000000002
# ╠═a1b2c3d4-1111-4000-a000-000000000021
# ╠═a1b2c3d4-1111-4000-a000-000000000003
# ╠═a1b2c3d4-1111-4000-a000-000000000004
# ╠═a1b2c3d4-1111-4000-a000-000000000020
# ╟─a1b2c3d4-1111-4000-a000-000000000030
# ╠═a1b2c3d4-1111-4000-a000-000000000031
# ╠═a1b2c3d4-1111-4000-a000-000000000032
# ╠═a1b2c3d4-1111-4000-a000-000000000033
# ╠═a1b2c3d4-1111-4000-a000-000000000034
# ╟─a1b2c3d4-1111-4000-a000-000000000035
# ╟─a1b2c3d4-1111-4000-a000-000000000040
# ╠═a1b2c3d4-1111-4000-a000-000000000041
# ╠═a1b2c3d4-1111-4000-a000-000000000042
# ╠═a1b2c3d4-1111-4000-a000-000000000043
# ╠═a1b2c3d4-1111-4000-a000-000000000044
# ╠═a1b2c3d4-1111-4000-a000-000000000045
# ╟─a1b2c3d4-1111-4000-a000-000000000046
# ╟─a1b2c3d4-1111-4000-a000-000000000050
# ╠═a1b2c3d4-1111-4000-a000-000000000051
# ╠═a1b2c3d4-1111-4000-a000-000000000052
# ╠═a1b2c3d4-1111-4000-a000-000000000053
# ╠═a1b2c3d4-1111-4000-a000-000000000054
# ╠═a1b2c3d4-1111-4000-a000-000000000055
# ╟─a1b2c3d4-1111-4000-a000-000000000056
# ╟─a1b2c3d4-1111-4000-a000-000000000060
# ╠═a1b2c3d4-1111-4000-a000-000000000061
# ╠═a1b2c3d4-1111-4000-a000-000000000062
# ╠═a1b2c3d4-1111-4000-a000-000000000063
# ╠═a1b2c3d4-1111-4000-a000-000000000064
# ╟─a1b2c3d4-1111-4000-a000-000000000065
# ╟─a1b2c3d4-1111-4000-a000-000000000070
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
