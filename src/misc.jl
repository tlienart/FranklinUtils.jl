"""
    html(s)

Mark a string as HTML to be included in Franklin-markdown. Line spacing is
to reduce issues with `<p>`.
"""
html(s) = "~~~$s~~~"


"""
    isapproxstr(s1, s2)

Check if two strings are similar modulo spaces and line returns.
"""
isapproxstr(s1, s2) =
    isequal(map(s->replace(s, r"\s|\n"=>""), String.((s1, s2)))...)

"""
    hfun_requiredfill(params::Vector{String})
H-Function similar to `hfun_fill`, but this function throws an error if a field is not set.
"""
function hfun_requiredfill(params::Vector{String})::String
    value = Franklin.hfun_fill(params)
    field = params[1]
    @assert(value != "", "Missing a value for the field $field")
    return value
end
