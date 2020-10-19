module FranklinUtils

import Franklin
const F = Franklin

# misc
export html, isapproxstr
# lx_tools
export lxd, lxproc, lxopts, lxargs, lxmock

include("misc.jl")
include("lx_tools.jl")

end # module
