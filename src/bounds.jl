struct BoxConstrainedSpace{T} <: AtomicSearchSpace
    lb::Vector{T} # lower bounds
    ub::Vector{T} # upper bounds
    Δ::Vector{T}  # = ub-lb
    dim::Int
    rigid::Bool
end

function _valid_bounds(lb, ub)
    if length(lb) != length(ub) || any(lb .> ub)
        return false
    end

    true
end

"""
    BoxConstrainedSpace(;lb, ub, rigid=true)

Define a search space delimited by box constraints.

# Example

```julia-repl
julia> space = BoxConstrainedSpace(lb = zeros(Int, 5), ub = ones(Int, 5))
BoxConstrainedSpace{Int64}([0, 0, 0, 0, 0], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], 5, true)

julia> cardinality(space)
32
```
"""
function BoxConstrainedSpace(lb::AbstractVector, ub::AbstractVector; rigid=true)
    @assert _valid_bounds(lb, ub) "Check size of lb and ub, and also lb[i] <= ub[i]."

    BoxConstrainedSpace(lb, ub, ub - lb, length(lb), rigid)
end

function BoxConstrainedSpace(;lb = zeros(0), ub = zeros(0), rigid=true)
    BoxConstrainedSpace(lb, ub; rigid)
end

function BoxConstrainedSpace(lb::Real, ub::Real; rigid=true)
    lb, ub = promote(lb, ub)
    BoxConstrainedSpace([lb], [ub]; rigid)
end

"""
    ..(a, b)
Define a interval between a and b (inclusive).

# Example

```julia-repl
julia> my_interval = (-π..π)

julia> rand(my_interval, 5)
5-element Vector{Float64}:
 0.5111482297554093
 1.1984728844571544
 1.3279941255812906
 2.3429444282250502
 3.0495310142685526
```

See also [`BoxConstrainedSpace`](@ref)
"""
..(a::Real, b::Real) = BoxConstrainedSpace(a, b)
..(a::Bool, b::Bool) = BitArraySpace(1)

function cardinality(searchspace::BoxConstrainedSpace{T}) where T <: Integer
    prod(searchspace.ub - searchspace.lb .+ one(T))
end

function cardinality(searchspace::BoxConstrainedSpace)
    Inf
end

"""
    isinbounds(item, searchspace) --> Bool

Determine whether an item is in the given searchspace.
"""
isinbounds(x, searchspace::BoxConstrainedSpace) = false

function isinbounds(x::AbstractVector{T}, searchspace::BoxConstrainedSpace{T}) where T <: Real
    if length(x) != getdim(searchspace)
        return false
    end
    
    all(searchspace.lb .<= x .<= searchspace.ub)
end

isinbounds(x::T, searchspace::BoxConstrainedSpace{T}) where T <: Real = first(searchspace.lb) <= x <= last(searchspace.ub)


isinspace(x, searchspace::BoxConstrainedSpace) = isinbounds(x, searchspace)

function _get_random(bounds::BoxConstrainedSpace{<:Integer}, rng)
    if getdim(bounds) == 1
        return rand(rng, bounds.lb[1]:bounds.ub[1])
    end

    [rand(rng, a:b) for (a, b) in zip(bounds.lb, bounds.ub)]
end

function _get_random(bounds::BoxConstrainedSpace, rng)
    if getdim(bounds) == 1
        return bounds.lb[1] + bounds.Δ[1] .* rand(rng)
    end
    bounds.lb + bounds.Δ .* rand(rng, getdim(bounds))
end

function value(sampler::Sampler{S, B}) where {S<:AbstractRNGSampler,B<:BoxConstrainedSpace}
    parameters = sampler.method
    searchspace = sampler.searchspace
    _get_random(searchspace, parameters.rng)
end

function Grid(bnds::BoxConstrainedSpace{T}; npartitions = 3) where T <: Integer
    d = getdim(bnds)
    it = Iterators.product(
                           (a:b for (a, b) in zip(bnds.lb, bnds.ub))...
                          )

    Sampler(Grid(npartitions, (it, nothing)), bnds, length(it))
end

function Grid(bnds::BoxConstrainedSpace; npartitions = 3)
    d = getdim(bnds)

    it = Iterators.product(
                           (
                            range(a, b, length = npartitions) 
                            for (a, b) in zip(bnds.lb, bnds.ub)
                           )...
                          )

    Sampler(Grid(npartitions, (it, nothing)), bnds, length(it))
end

