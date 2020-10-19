@testset "html" begin
    @test html("aaa") == "~~~aaa~~~"
end

@testset "isapproxstr" begin
    @test isapproxstr("  aa b c\n", "a a b c")
end
