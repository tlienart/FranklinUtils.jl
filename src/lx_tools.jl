"""
    lxd(n)

Create a dummy latex definition (useful for testing).
"""
lxd(n) = F.LxDef("\\" * n, 1, F.subs(""))

"""
    lxproc(com)

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
    # unpack if multiple kwargs are given
    if !isempty(args) && args[1] isa Expr && args[1].head == :parameters
        nokw = args[2:end]
        args = [nokw..., args[1].args...]
        i = length(nokw) + 1
    else
        i = findfirst(e -> isa(e, Expr) && e.head in (:(=), :parameters), args)
    end
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
        elseif arg isa Expr
            push!(proc_args, eval(arg))
        else
            push!(proc_args, arg)
        end
    end
    all(e -> e isa Expr, cand_kwargs) || error("""
        In command/env $fname, expected arguments followed by keyword arguments but got:
        $s; verify.""")
    cand_kwargs = map(e -> e.head == :parameters ? e.args : e, cand_kwargs)
    for kwarg in cand_kwargs
        v = kwarg.args[2]
        if v isa Expr
            v = eval(v)
        end
        push!(proc_kwargs, kwarg.args[1] => v)
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

"""
    @lx

Streamlines the creation of a "latex-function".
"""
macro lx(defun)
    def   = splitdef(defun)
    name  = def[:name]
    body  = def[:body]
    name_ = String(name)
    lxn_  = Symbol("lx_$(name)")
    fbn_  = Symbol("_lx_$(name)")

    def[:name] = fbn_
    ex = quote
        eval(FranklinUtils.combinedef($def))
        function $lxn_(c, _)
            a, kw = lxargs(lxproc(c), $name_)
            return $fbn_(a...; kw...)
        end
    end
    esc(ex)
end

"""
    @env

Same as [`@lx`](@ref) but for environments
"""
macro env(defun)
    def   = splitdef(defun)
    name  = def[:name]
    body  = def[:body]
    name_ = String(name)
    lxn_  = Symbol("env_$(name)")
    fbn_  = Symbol("_env_$(name)")

    def[:name] = fbn_
    ex = quote
        eval(FranklinUtils.combinedef($def))
        function $lxn_(e, _)
            _, kw = lxargs(lxproc(e), $name_)
            return $fbn_(Franklin.content(e); kw...)
        end
    end
    esc(ex)
end
