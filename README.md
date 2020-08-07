# FranklinUtils.jl

[![Build Status](https://travis-ci.com/tlienart/FranklinUtils.jl.svg?branch=master)](https://travis-ci.com/tlienart/FranklinUtils.jl)
[![Coverage](https://codecov.io/gh/tlienart/FranklinUtils.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/tlienart/FranklinUtils.jl)

This package aims to simplify building plugins for [Franklin](https://github.com/tlienart/Franklin.jl) in particular the definition of

* `hfun_*` (functions which will be called with `{{fname ...}}` either from Markdown or from HTML),
* `lx_*` (functions which will be called with `\fname{...}` from Markdown only).

**Which one should you use?**: both can be useful, as a rough guideline, `hfun_*` are simpler and `lx_*` are more flexible.
If you would like to build a plugin package (e.g.: something like [FranklinBootstrap.jl](ADD_LINK_HERE) which makes it easy to work with Bootstrap), you should generally prefer `lx_*` as they will offer more flexibility, particularly in dealing with arguments etc.
The present package will be particularly helpful for definitions of `lx_*` commands.

## Where to put definitions

### General user

You should put the definition of the `lx_*` and `hfun_*` function in the `utils.jl` file.

**Note**: the `utils.jl` file can itself load other packages or include other files.

### Package developper

Say you're developping a package like `FranklinBootstrap`, then the corresponding module would export all `lx_*` and `hfun_*` definitions that you want to make available.

Users of your package should then just add in their `utils.jl` file either:

```
using FranklinBootstrap
```

or

```
import FranklinBootstrap: lx_fun1, lx_fun2, hfun_3
```

depending on whether they want a finer control over what they want to use (the former should be preferred).


## Defining `hfun_*`

Let's say we want to define a function `hfun_foo` which will be called `{{foo ...}}`.
To define such a function, we must write:

```
function hfun_foo(...)::String
    # definition
    return html_string
end
```

that function **must** return a (possibly empty) String which is expected to be in HTML format.

### Arguments

#### No arguments

You could have a function without argument which would then be called `{{foo}}`.
For this, without surprise, just leave the arguments empty in the definition:

```
function hfun_foo()::String
    # definition
    return html_string
end
```

#### With arguments

Arguments are passed as a string separated by spaces and passed as a `Vector{String}`, it is _expected_ that these strings correspond to names of page variables though of course you can do whatever you want with them.

The _expected_ workflow is:

1. define some page variables `var1`, `var2` (note that the definition can itself use Julia code),
1. call the function with `{{foo var1 var2}}`
1. the function `hfun_foo` checks the page variables `var1` and `var2`, accesses their value and proceeds.

In all cases, the definition must now look like

```
function hfun_foo(args::Vector{String})::String
    # definition
    return html_string
end
```

the difference will lie in how you process the `args`.

### Access to page variables

In both `hfun_*` and `lx_*` function you have access to the page variables defined on the page which calls the function and to page variables defined on other pages.

To access _local_ page variables, call `locvar("$name_of_var")`, to access a page variable defined on another page, call `pagevar("$relative_path", "$name_of_var")` where `$relative_path` is the path to the page that defines the variable.
In both case, if the variable is not found then `nothing` is returned.

**Example**: page `bish/blah.md` defines `var1`, you can access it via `locvar("var1")` for any function called on `blah.md` and via `pagevar("bish/blah")` anywhere else.

**Note**: the relative path for `pagevar` can have the extension, it will be ignored so `"bish/blah.md"` or `"bish/blah"` will be interpreted identically.

### Examples

#### Example 1

In file `blah.md`

```
{{foo}}
```

In file `utils.jl`

```
function hfun_foo()
    return "<h1>Hello!</h1>"
end
```

#### Example 2

In file `blah.md`

```
@def var1 = 5
{{foo var1}}
```

In file `utils.jl`

```
function hfun_foo(args)
    vname = args[1]
    val = locvar(vname)
    io = IOBuffer()
    for i in 1:val
        write(io, "<p>" * "*"^i * "</p>")
    end
    return String(take!(io))
end
```

---

## Defining `lx_*`

Let's say we want to define a function `lx_bar` which will be called `\bar{...}`.
To define such a function, we must write:

```
function lx_bar(lxc, lxd)::String
    # definition
    return markdown_string
end
```

that function **must** return a (possibly empty) String which is expected to be in HTML format.

### Arguments

* `lxc` is a Franklin object which essentially contains the content of the braces.
* `lxd` is a Franklin object which contains all the LaTeX-like definitions that have been defined up to the point where `\bar` is called, you should generally not use it.

The **recommended** workflow is to use the `lxargs` function from `FranklinUtils` to read the content of the first brace as if it was the arguments passed to a Julia function:

```
function lx_bar(lxc, _)
    args, kwargs = lxargs(lxc)
    # work with args, kwargs
    return markdown_string
end
```

**Note**: a `lx_*` function can also build raw HTML, in that case just use the `html` function at the end so that it gets considered as such e.g.: `return html(html_string)`.

## Notes

### Nesting

...
