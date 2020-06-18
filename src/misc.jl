"""
    html(s)

Mark a string as HTML to be included in Franklin-markdown. Line spacing is
to reduce issues with `<p>`.
"""
html(s) = "\n~~~$s~~~\n"


"""
    isapproxstr(s1, s2)

Check if two strings are similar modulo spaces and line returns.
"""
isapproxstr(s1, s2) =
    isequal(map(s->replace(s, r"\s|\n"=>""), String.((s1, s2)))...)
