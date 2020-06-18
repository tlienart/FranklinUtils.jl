@testset "html" begin
    @test html("aaa") == "\n~~~aaa~~~\n"
end

@testset "isapproxstr" begin
    @test isapproxstr("  aa b c\n", "a a b c")
end
