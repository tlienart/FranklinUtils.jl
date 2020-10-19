"""
    lxd(n)

Create a dummy latex definition (useful for testing).
"""
lxd(n) = F.LxDef("\\" * n, 1, F.subs(""))

"""
    lxopts(com)

Extract the content of a single-brace lx command. For instance `\\com{foo}`
would be extracted to `foo`.
"""
lxproc(com) = F.content(com.braces[1])

"""
    lxargs(s)

Extract function-style arguments.
Expect (arg1, arg2, ..., name1=val1, name2=val2, ...)

Example:

    julia> a = ":section, 1, 3, title=\"hello\", name=\"bar\""
    julia> lxargs(a)
    (Any[:section, 1, 3], Any[:title => "hello", :name => "bar"])
"""
function lxargs(s, fname="")
    isempty(s) && return [], []
    s = "(" * s * ",)"
    args = nothing
    try
        args = Meta.parse(s).args
    catch
        error("A command/env $fname had improper options:\n$s; verify.")
    end
    i = findfirst(e -> isa(e, Expr), args)
    if isnothing(i)
        cand_args = args
        cand_kwargs = []
    else
        cand_args = args[1:i-1]
        cand_kwargs = args[i:end]
    end
    proc_args   = []
    proc_kwargs = []
    for arg in cand_args
        if arg isa QuoteNode
            push!(proc_args, arg.value)
        else
            push!(proc_args, arg)
        end
    end
    for kwarg in cand_kwargs
        kwarg isa Expr || error("In command/env $fname, expected arguments " *
                                "followed by keyword arguments but got: " *
                                "$s; verify.")
        push!(proc_kwargs, kwarg.args[1] => kwarg.args[2])
    end
    return proc_args, proc_kwargs
end

"""
    lxarg(com)

For a LxCom, extract the first brace and process as function arguments.
"""
lxargs(com::F.LxObj) = lxargs(lxproc(com), F.getname(com))


"""
    lxmock(s)

Creates a mock command from a string so that it can be parsed as
a Franklin.LxCom.
"""
function lxmock(s)
    F.def_GLOBAL_LXDEFS!()
    empty!(F.GLOBAL_LXDEFS)
    # create a dummy command with the name
    name = match(r"\\(.*?)\{", s).captures[1]
    F.GLOBAL_LXDEFS[name] = lxd(name)
    # parse looking for the comand
    tokens = F.find_tokens(s, F.MD_TOKENS, F.MD_1C_TOKENS)
    blocks, tokens = F.find_all_ocblocks(tokens, F.MD_OCB2)
    lxdefs, tokens, braces, _ = F.find_lxdefs(tokens, blocks)
    lxdefs = cat(collect(values(F.GLOBAL_LXDEFS)), lxdefs, dims=1)
    lxcoms, _ = F.find_lxcoms(tokens, lxdefs, braces)
    # return the lxcom
    return lxcoms[1]
end
