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

@testset "lx-macro" begin
    # single arg
    c = lxmock(raw"""\foo{"bar"}""")
    @lx foo(s) = "A-$s-B"
    @test lx_foo(c, NaN) == "A-bar-B"
    # two args
    c = lxmock(raw"""\bar{"aa", "bb"}""")
    @lx bar(s1, s2) = "A-$s1-B-$s2-C"
    @test lx_bar(c, NaN) == "A-aa-B-bb-C"
    # array args
    c = lxmock(raw"""\baz{[1,2,3]}""")
    @lx baz(a) = "A-$(sum(a))-B"
    @test lx_baz(c, NaN) == "A-6-B"
    # kwargs
    c = lxmock(raw"""\foo{a=5}""")
    @lx foo(;a=5) = "A-$a-B"
    @test lx_foo(c, NaN) == "A-5-B"
    # mix of everything
    c = lxmock(raw"""\foo{"bar"; a=5, b=[1,2,3]}""")
    @lx foo(s; a=0, b=[1,2]) = "A-$s-$a-$(sum(b))-B"
    @test lx_foo(c, NaN) == "A-bar-5-6-B"
    c = lxmock(raw"""\foo{"bar", (1, 2, 3); a=5, b=[1,2,3]}""")
    @lx foo(s, s2; a=0, b=[1,2]) = "A-$s-$(sum(s2))-$a-$(sum(b))-B"
    @test lx_foo(c, NaN) == "A-bar-6-5-6-B"
end
