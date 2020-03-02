struct CrystalOperator
    C::Crystal ## dimension L.dim dictates size of Multiplier.pos and dim of structure elements.
    M::SortedSet{Multiplier}# Array{Multiplier,1}
    _CompatibilityCheckOnly::Bool
    function CrystalOperator(
        C::Crystal,
        M::SortedSet{Multiplier},
        _CompatibilityCheckOnly::Bool,
    )
        _sanitycheck(C, M)
        new(C, M, _CompatibilityCheckOnly)
    end
end

function CrystalOperator(
    C = nothing,
    M = nothing,
    _CompatibilityCheckOnly = false,
)
    if C == nothing
        C = Crystal()
    end
    if M == nothing
        M = SortedSet{Multiplier}()
    end
    return CrystalOperator(C, M, _CompatibilityCheckOnly)
end

function _sanitycheck(C::Crystal, m::Multiplier) # check dimensionality and size:
    #dim / pos:
    @assert m.dim == C.dim "Multiplier dimension m.dim=length(m.pos)=$(m.dim) must be equal to Lattice dimension S.C.dim=size(S.C.L,1)=$(C.dim)"
    #size domain, codomain
    @assert m.size_domain == C.size_domain "Multiplier domain size m.size_domain=size(m.mat,2)=$(m.size_domain) must be equal to size of the (structure element of the) Domain C.size_domain=size(C.Domain,1)=$(C.size_domain)"
    @assert m.size_codomain == C.size_codomain "Multiplier codomain size m.size_codomain=size(m.mat,1)=$(m.size_codomain) must be equal to size of the (structure element of the) Domain C.size_codomain=size(C.Codomain,1)=$(C.size_codomain)"
    return true
end

function _sanitycheck(C::Crystal, M::SortedSet{Multiplier})
    for m in M
        _sanitycheck(C, m)
    end
end

function Base.push!(S::CrystalOperator, m::Multiplier)
    _sanitycheck(S.C, m)
    push!(S.M, m)
    return S
end


function Base.show(io::IO, mime::MIME"text/plain", s::SortedSet{Multiplier})
    show(io, mime, collect(s))
end

function Base.show(io::IO, mime::MIME"text/plain", o::CrystalOperator)
    show(io, mime, o.C)
    print(io, "\nMultiplier: ")
    show(io, mime, o.M)
end

function normalize(S::CrystalOperator)
    (dn, ds, dp) = ShiftIntoUnitCell(S.C.Domain, S.C.L)
    (cn, cs, cp) = ShiftIntoUnitCell(S.C.Codomain, S.C.L)

    # ...
    m_old = collect(S.M)
    y_old = vcat(transpose([x.pos for x in S.M])...)



end


function wrtLattice(S::CrystalOperator, A::Matrix)
    #### TODO: Test this function, when Plot function exists. Need to construct test cases with alfa.py.

    t = ElementsInQuotientSpace(S.C.A, A, fractional = true)
    #t = [0 0; 1 0; 0 1; 1 1]
    #println("t: ", t)
    newDomain = vcat(transpose([
        x + y for x in eachslice(t, dims = 1)
        for y in eachslice(S.C.Domain, dims = 1)
    ])...)
    newCodomain = vcat(transpose([
        x + y for x in eachslice(t, dims = 1)
        for y in eachslice(S.C.Codomain, dims = 1)
    ])...)

    m_old = collect(S.M)
    y_old = vcat(transpose([x.pos for x in S.M])...)
    Ay_old = transpose(S.C.L.A * transpose(y_old))
    # find all unique combinations of floor(A\S.C.L.A*(y_old[i] + t[j] - t[k]))
    #SS0 = SortedSet{Array{Int,1}}()
    SS0 = SortedDict{Array{Int,1},Array{Tuple{Int,Int},1}}()
    ### TODO: MOST TIME SPEND IN FOLLOWING for loop.
    ### IT can explicitly computed using
    # dH = alfa.ElementsInQuotientSpace(S.C.A, A, return_diag_hnf=true)
    # and
    # collect(Iterators.product([-x+1:x-1 for x in dH]...)) # <-- all combinations of ti-tj
    # need a formula to obtain i and j from this thing.
    @time for (it_ti, ti) in enumerate(eachslice(t, dims = 1))
        for (it_tj, tj) in enumerate(eachslice(t, dims = 1))
            push!(
                get!(SS0, ti - tj, Array{Tuple{Int64,Int64},1}()),
                (it_ti, it_tj),
            )
        end
    end
    SS = SortedSet{Array{Int,1}}()
    for j in Iterators.product(eachslice(y_old, dims = 1), keys(SS0))
        y = A \ (S.C.L.A * (j[1] + j[2]))
        map!(
            x -> isapprox(x, round(x), rtol = alfa_rtol, atol = alfa_atol) ?
                round(x) : floor(x),
            y,
            y,
        )
        push!(SS, y)
    end
    y_new = vcat(transpose(collect(SS))...)
    #println("y_new", y_new)
    Ay_new = transpose(A * transpose(y_new)) # convert to cartesian coordinate of original lattice.
    #Ay_new = y_new
    # get coordinate of new lattice
    #println("Ay_new: ", Ay_new)
    #println("Ay_old:", Ay_old)
    # assign multipliers.

    brs = S.C.size_codomain #block row size
    bcs = S.C.size_domain #block column size

    Cnew = Crystal(A, newDomain, newCodomain)
    op = CrystalOperator(Cnew)
    for (it_y, y) in enumerate(eachslice(Ay_new, dims = 1))
        #println("y_new: ",y)
        mm = nothing

        for (tdiff, ss_ij) in SS0

            #for (it_ti, ti) in enumerate(eachslice(t, dims = 1))
            #for (it_tj, tj) in enumerate(eachslice(t, dims = 1))
            #y_test = y - ti + tj
            y_test = y - tdiff
            #println("y_test  $y_test , it (i,j) = ($it_ti, $it_tj)")
            for (it_yk, yk) in enumerate(eachslice(Ay_old, dims = 1))
                #print("yk $yk")
                if isapprox(yk, y_test, rtol = alfa_rtol, atol = alfa_atol)
                    #println("#####################TRUE : yk:   $yk")
                    matblock = m_old[it_yk].mat
                    #println("matblock: $matblock")
                    if mm == nothing
                        mm = zeros(
                            typeof(first(S.M).mat[1, 1]),
                            Cnew.size_codomain,
                            Cnew.size_domain,
                        ) # init new matrix.
                    end
                    for (it_ti, it_tj) in ss_ij
                        mm[
                            (it_ti-1)*brs+1:it_ti*brs,
                            (it_tj-1)*bcs+1:it_tj*bcs,
                        ] = matblock
                    end
                    break
                end

                #end
            end
        end
        if mm != nothing
            push!(op, Multiplier(y_new[it_y, :], mm))
        end
    end
    return op
end
