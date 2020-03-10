using alfa
using Test
import DataStructures: SortedSet

@testset "crystaloperator.jl" begin
    @test isa(alfa.CrystalOperator(), alfa.CrystalOperator) == true

    C = alfa.Crystal([1 0; 0 1], [0 0; 0.25 0.25; 0.5 0.5], [0 0; 0.25 0.25])
    @test isa(C, alfa.Crystal) == true

    CO = alfa.CrystalOperator(C)
    @test isa(CO, alfa.CrystalOperator) == true
    #
    m_wrong_matsize1 = alfa.Multiplier([1 1], [1 2; 3 4])
    m_wrong_matsize2 = alfa.Multiplier([1 1], [1 2 3 4; 5 6 7 8])
    m_wrong_dim = alfa.Multiplier([1 2 3], [1 2 3; 4 5 6])
    @test_throws AssertionError push!(CO, m_wrong_matsize1)
    @test_throws AssertionError push!(CO, m_wrong_matsize2)
    @test_throws AssertionError push!(CO, m_wrong_dim)


    m12 = alfa.Multiplier([1 2], [1 2 3; 4 5 6])
    @test isa(push!(CO, m12), alfa.CrystalOperator) == true

    # Define a sorted set which works fine.
    m12 = alfa.Multiplier([1 2], [1 2 3; 4 5 6])
    m13 = alfa.Multiplier([1 3], [1 2 3; 4 5 6])


    mymults1 = SortedSet{alfa.Multiplier}([m13, m12])

    mymults2 = SortedSet{alfa.Multiplier}()
    push!(mymults2, m12)
    push!(mymults2, m13)

    @test collect(mymults1) == collect(mymults2)
    @test isa(alfa.CrystalOperator(C, mymults2), alfa.CrystalOperator) == true

    mymults3 = SortedSet{alfa.Multiplier}([m13, m_wrong_dim])
    @test_throws AssertionError alfa.CrystalOperator(C, mymults3)
    mymults3 = SortedSet{alfa.Multiplier}([m13, m_wrong_matsize1])
    @test_throws AssertionError alfa.CrystalOperator(C, mymults3)
    mymults3 = SortedSet{alfa.Multiplier}([m13, m_wrong_matsize2])
    @test_throws AssertionError alfa.CrystalOperator(C, mymults3)

    @test isa(alfa.gallery(), alfa.CrystalOperator)
    O = alfa.gallery("Laplacian2D")
    @test isa(O, alfa.CrystalOperator)
    ## do stuff with O.

    # @test show(O.M) == nothing
    # @test show(O) == nothing


    # test find_multiplier
    @test alfa.find_multiplier(O,[12, 12]) == nothing
    @test alfa.find_multiplier(O,[0, 0]) isa alfa.Multiplier


    # test wrtLattice
    S = alfa.gallery()
    S2 = alfa.wrtLattice(S, 2*S.C.L.A)
    mult = alfa.Multiplier([0, 0], [-4 1 1 0; 1 -4 0 1; 1 0 -4 1; 0 1 1 -4])
    mult_orig = deepcopy(mult)
    @test alfa.find_multiplier(push!(S2, mult), [0, 0]).mat == mult_orig.mat
    @test alfa.find_multiplier(push!(S2, mult, true), [0, 0]).mat == 2*mult_orig.mat
    # @test alfa.find_multiplier(push!(O, mult), [0, 0]).mat == [-4]
    # @test alfa.find_multiplier(push!(O, mult, true), [0, 0]).mat == [-8]

    @test S2 == deepcopy(S2)
    @test S != S2
end
