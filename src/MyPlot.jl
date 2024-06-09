# —————————————————————————————————————————————————————————————————————————————————————— #
#            Plotting Library setup with useful constants and helper functions           #
# —————————————————————————————————————————————————————————————————————————————————————— #
module MyPlot

export set_style
export markero, markerx, markery, markers
export CM, WIDTH, GOLDEN_RATIO
export polygon_under_graph, gradient_line, truncate_colormap
export make_iterable
export sns

using Reexport
@reexport using PyPlot # Exports things like LatexStrings that are needed!
@reexport using PyCall
@reexport using Printf # @sprintf for formatted output statements

const sns = PyNULL() # explicitly imported in the __init__() function

# Make single instance of axis object iterable
make_iterable(ax) = typeof(ax) <: PyObject ? [ax] : ax

# ——————————————————————————— Change the mplstyle file to use —————————————————————————— #
"""
    set_style(key::Symbol= :std)

Setup :key plotting evironment, with key=:std (default) or `key ∈ [paper, std, experimental]`.

New styles can be added by generating the corresponding `.mplstyle` file in the styles folder
`return:` PyPlot (is also exported by the module)
"""
function set_style(key::Symbol= :std)
    plt.style.use("default") # Reset to default style
    path = dirname(@__DIR__)*"/styles/$key.mplstyle"
    plt.style.use(path) # Reset to default style
    plt.matplotlib.use("TkAgg") # alternative Qt5Agg
    return PyPlot
end

# —————————————————————————————— Indexing gridspec object —————————————————————————————— #
slice(i,j) = pycall(pybuiltin("slice"), PyObject, i,j)

# getindex with integer is implemented in PyCall, but it is deprecated!
# Below custom version "just in case"
# Base.getindex(A::PyObject, i::Integer, j::Integer) = get(A, (i-1, j - 1))
function Base.getindex(A::PyObject, r::UnitRange{<:Integer}, j::Integer)
    r_start = r[1];  r_end = r[end]
    r_start > r_end && error("Empty UnitRange!")

    return get(A, (slice(r_start-1, r_end), j - 1))
end
function Base.getindex(A::PyObject, i::Integer, r::UnitRange{<:Integer})
    r_start = r[1];  r_end = r[end]
    r_start > r_end && error("Empty UnitRange!")
    return get(A, (i-1, slice(r_start-1, r_end)))
end
function Base.getindex(A::PyObject, r1::UnitRange{<:Integer}, r2::UnitRange{<:Integer})
    r1_start = r1[1];  r1_end = r1[end]
    r2_start = r2[1];  r2_end = r2[end]

    r2_start > r2_end && error("Empty UnitRange!")
    r1_start > r1_end && error("Empty UnitRange!")

    return get(A, (slice(r1_start-1, r1_end), slice(r2_start-1, r2_end)))
end

# ——————————————————————————————— Polygons and gradients ——————————————————————————————— #
# Usage illustrated in the test section
"""
    polygon_under_graph(x::AbstractVector, y::AbstractVector)

Construct the vertex list which defines the polygon filling the space under
the (x, y) line graph. This assumes x is in ascending order.
"""
function polygon_under_graph(x::AbstractVector, y::AbstractVector)
    return [(x[1], 0.), zip(x, y)..., (x[end], 0.)]
end

"""
    gradient_line(ax, x, y, color_name, segments = 100)

Plot line y = f(x) with color gradient along the curve. The gradient is generated as `segments`
seperate curves, picked from `color_name` color_map.
"""
function gradient_line(ax, x, y, color_name, segments = 100)
    N = length(x) - 1
    Ns = N ÷ segments
    colors = sns.color_palette(color_name, segments)

    for i in 1:segments
        upper = i == segments ? N : (i * Ns)
        lower = i == 1 ?  1 + (i - 1) * Ns : (i - 1) * Ns
        ax.plot(x[lower:upper], y[lower:upper], color = colors[i])
    end
    return nothing
end

"""
    truncate_colormap(cmap, minval=0.0, maxval=1.0, n=100)

Truncate or extend colormap. The original colormap is given by minval=0, maxval=1.

# Arguments
- `minval(= 0):` Lower-bound of truncation. Zero means no truncation
- `maxval(= 1):` Upper-bound of truncation. One means no truncation
- `n(= 100):` Number of "sections" in the colormap
- `returns:` Truncated colormap
"""
function truncate_colormap(cmap, minval=0.0, maxval=1.0, n=100)
    # temp = @sprintf "trunc(%s,%.2f,%.2f)" cmap.name minval maxval
    temp = "trunc($(cmap.name),$minval,$maxval)"
    new_cmap = plt.matplotlib.colors.LinearSegmentedColormap.from_list(
        temp, cmap(range(minval, maxval, length=n)))
    return new_cmap
end

# ————————————————————————————— Development plotting styles ———————————————————————————— #
markero = Dict(:marker=>".", :linestyle=>"None", :markersize=>3)
markerx = Dict(:marker=>"x", :linestyle=>"None", :markersize=>3)
markery = Dict(:marker=>"1", :linestyle=>"None", :markersize=>3)
markers = Dict(:marker=>"s", :linestyle=>"None", :markersize=>3)

# —————————————————————————————————— Useful parameters ————————————————————————————————— #
const CM = 1/2.54
const WIDTH = 15*CM
const GOLDEN_RATIO = 1/2 * (1 + √5)

# Init function is called whenever MyPlot is included via using or import
function __init__()
    copy!(sns, pyimport("seaborn")) # Import seaborn package

    # Setup with default plot options
    PyPlot.plt.style.use("default") # Reset to default style
    path = dirname(@__DIR__)*"/styles/std.mplstyle"
    PyPlot.plt.style.use(path) # Reset to default style
    PyPlot.matplotlib.use("TkAgg") # alternative Qt5Agg

    return nothing
end

end # module
