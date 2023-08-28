using SpecialFunctions
using MyPlot

ax = plt.figure().add_subplot(projection="3d")

x = 0:0.001:10
lambdas = 1:9

verts = [polygon_under_graph(x, (@. l^x * exp(-l) / gamma(x + 1))) for l in lambdas]
facecolors = sns.color_palette("viridis_r", length(verts))

poly = plt.matplotlib.collections.PolyCollection(verts, facecolors=facecolors, alpha=.7)
ax.add_collection3d(poly, zs=lambdas, zdir="y")

ax.set(xlim=(0, 10), ylim=(1, 9), zlim=(0, 0.35))

plt.show()
