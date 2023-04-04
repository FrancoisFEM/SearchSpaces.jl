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

function GridSampler(bnds::BoxConstrainedSpace{T}; npartitions = 3) where T <: Integer
    d = getdim(bnds)
    it = Iterators.product(
                           (a:b for (a, b) in zip(bnds.lb, bnds.ub))...
                          )

    Sampler(GridSampler(npartitions, (it, nothing)), bnds, length(it))
end

function GridSampler(bnds::BoxConstrainedSpace; npartitions = 3)
    d = getdim(bnds)

    it = Iterators.product(
                           (
                            range(a, b, length = npartitions) 
                            for (a, b) in zip(bnds.lb, bnds.ub)
                           )...
                          )

    Sampler(GridSampler(npartitions, (it, nothing)), bnds, length(it))
end

