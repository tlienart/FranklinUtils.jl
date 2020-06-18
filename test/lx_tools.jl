@testset "lxproc" begin
    c = lxmock(raw"\foo{bar baz}")
    @test lxproc(c) == "bar baz"
end

@testset "lxargs" begin
    s = """
        :section, 1, 3, title="hello", foo="bar", a=5
        """
    a, ka = lxargs(s)
    @test all(a .== (:section, 1, 3))
    @test all(ka .== (
        :title => "hello",
        :foo => "bar",
        :a => 5))
    s = """
        title=5, foo="bar"
        """
    a, ka = lxargs(s)
    @test isempty(a)
    @test all(ka .== (:title => 5, :foo => "bar"))
    s = """
        5, 3
        """
    a, ka = lxargs(s)
    @test isempty(ka)
    @test all(a .== (5, 3))
    # bad ordering
    s = """
        5, a=3, 2
        """
    @test_throws ErrorException lxargs(s)
end
