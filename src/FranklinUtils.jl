module FranklinUtils

import Franklin
const F = Franklin

import ExprTools: splitdef, combinedef

# misc
export html, isapproxstr, hfun_requiredfill
# lx_tools
export lxd, lxproc, lxargs, lxmock, @lx, @env

include("misc.jl")
include("lx_tools.jl")

end # module
