using ALFA
using Test
using StaticArrays

@testset "crystal.jl" begin
    for T in [Float64, Rational{BigInt}]
        @test_throws Exception ALFA.Crystal{T}([1 0; 0 1], [1 2 3])
        @test_throws Exception ALFA.Crystal{T}([1 0; 0 1], [1 2], [1 2 3])
        @test_throws Exception ALFA.Crystal{T}([1 0; 0 1], [1 2 + 1im])

        C = ALFA.Crystal{2,T}()
        @test isa(C, ALFA.Crystal) == true
        C = ALFA.Crystal{1,T}([1], [1; 1.5], [1; 1.5])
        @test isa(C, ALFA.Crystal) == true
        C = ALFA.Crystal{2,T}(nothing, nothing, nothing)
        @test isa(C, ALFA.Crystal) == true
        C = ALFA.Crystal{2,T}([3 0; 0 2], [1 2; 3 4; 5 6], [1 2; 3 4; 5.0 6; 7 8])
        @test isa(C, ALFA.Crystal) == true
        C = ALFA.Crystal{2,T}(
            [3 0; 0 2],
            [[1, 2], [3, 4], [5, 6]],
            [[1, 2], [3, 4], [5, 6], [7, 8]],
        )
        @test isa(C, ALFA.Crystal) == true
        @test isa(C, ALFA.Crystal) == true
        C = ALFA.Crystal{2,T}(
            [10 0; 0 20],
            [[1 2], [3 4], [5 6]],
            [[1 2], [3 4], [5 6], [7 8]],
        )


        #getproperty tests
        @test C.size_domain == 3
        @test C.size_codomain == 4
        @test C.dim == 2
        @test C.A == C.L.A

        @test C == deepcopy(C)
        @test C !=
              ALFA.Crystal{2,T}([3 0; 0 2], [1 2; 3 4; 5 6], [1 2; 3 4; 5 6; 7 8])

        L = ALFA.Lattice{2,T}(C.A * [1 2; -3 4])

        C2 = ALFA.wrtLattice(C, L)

        @test [10.0 20.0; -60.0 80.0] == C2.L.A
        @test C2.Domain == SArray{Tuple{2},T,1,2}[
            [1.0, 2.0],
            [3.0, 4.0],
            [5.0, 6.0],
            [1.0, 22.0],
            [3.0, 24.0],
            [5.0, 26.0],
            [1.0, 42.0],
            [3.0, 44.0],
            [5.0, 46.0],
            [1.0, 62.0],
            [3.0, 64.0],
            [5.0, 66.0],
            [1.0, 82.0],
            [3.0, 84.0],
            [5.0, 86.0],
            [1.0, 102.0],
            [3.0, 104.0],
            [5.0, 106.0],
            [1.0, 122.0],
            [3.0, 124.0],
            [5.0, 126.0],
            [1.0, 142.0],
            [3.0, 144.0],
            [5.0, 146.0],
            [1.0, 162.0],
            [3.0, 164.0],
            [5.0, 166.0],
            [1.0, 182.0],
            [3.0, 184.0],
            [5.0, 186.0],
        ]
        @test C2.Codomain == SArray{Tuple{2},T,1,2}[
            [1.0, 2.0],
            [3.0, 4.0],
            [5, 6.0],
            [7.0, 8.0],
            [1.0, 22.0],
            [3.0, 24.0],
            [5.0, 26.0],
            [7.0, 28.0],
            [1.0, 42.0],
            [3.0, 44.0],
            [5.0, 46.0],
            [7.0, 48.0],
            [1.0, 62.0],
            [3.0, 64.0],
            [5.0, 66.0],
            [7.0, 68.0],
            [1.0, 82.0],
            [3.0, 84.0],
            [5.0, 86.0],
            [7.0, 88.0],
            [1.0, 102.0],
            [3.0, 104.0],
            [5.0, 106.0],
            [7.0, 108.0],
            [1.0, 122.0],
            [3.0, 124.0],
            [5.0, 126.0],
            [7.0, 128.0],
            [1.0, 142.0],
            [3.0, 144.0],
            [5.0, 146.0],
            [7.0, 148.0],
            [1.0, 162.0],
            [3.0, 164.0],
            [5.0, 166.0],
            [7.0, 168.0],
            [1.0, 182.0],
            [3.0, 184.0],
            [5.0, 186.0],
            [7.0, 188.0],
        ]

        C2n = ALFA.normalize(C2)
        @test C2n.Domain == SArray{Tuple{2},T,1,2}[
            [1.0, 2.0],
            [3.0, -16.0],
            [3.0, 4.0],
            [5.0, -14.0],
            [5.0, 6.0],
            [11.0, -38.0],
            [11.0, -18.0],
            [11.0, 2.0],
            [11.0, 22.0],
            [11.0, 42.0],
            [13.0, -36.0],
            [13.0, -16.0],
            [13.0, 4.0],
            [13.0, 24.0],
            [13.0, 44.0],
            [15.0, -34.0],
            [15.0, -14.0],
            [15.0, 6.0],
            [15.0, 26.0],
            [15.0, 46.0],
            [21.0, 2.0],
            [21.0, 22.0],
            [21.0, 42.0],
            [21.0, 62.0],
            [23.0, 4.0],
            [23.0, 24.0],
            [23.0, 44.0],
            [25.0, 6.0],
            [25.0, 26.0],
            [25.0, 46.0],
        ]
        @test C2n.Codomain == SArray{Tuple{2},T,1,2}[
            [1.0, 2.0],
            [3.0, -16.0],
            [3.0, 4.0],
            [5.0, -14.0],
            [5.0, 6.0],
            [7.0, -32.0],
            [7.0, -12.0],
            [7.0, 8.0],
            [7.0, 28.0],
            [11.0, -38.0],
            [11.0, -18.0],
            [11.0, 2.0],
            [11.0, 22.0],
            [11.0, 42.0],
            [13.0, -36.0],
            [13.0, -16.0],
            [13.0, 4.0],
            [13.0, 24.0],
            [13.0, 44.0],
            [15.0, -34.0],
            [15.0, -14.0],
            [15.0, 6.0],
            [15.0, 26.0],
            [15.0, 46.0],
            [17.0, -12.0],
            [17.0, 8.0],
            [17.0, 28.0],
            [17.0, 48.0],
            [17.0, 68.0],
            [21.0, 2.0],
            [21.0, 22.0],
            [21.0, 42.0],
            [21.0, 62.0],
            [23.0, 4.0],
            [23.0, 24.0],
            [23.0, 44.0],
            [25.0, 6.0],
            [25.0, 26.0],
            [25.0, 46.0],
            [27.0, 28.0],
        ]
    end
end
