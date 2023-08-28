using MyPlot

fig = figure()
gs = fig.add_gridspec(3,2)

ax = fig.add_subplot(gs[2, 2])
ax.plot(sin.(-pi:0.1:pi))

ax = fig.add_subplot(gs[1, 2])
ax.plot(cos.(-pi:0.1:pi))

ax = fig.add_subplot(gs[1:2, 1])
ax.plot(-pi:0.1:pi |> collect)

ax = fig.add_subplot(gs[3, 1])
ax.plot(rand(5), rand(5))
plt.show()

## Alternative
gridspec = plt.matplotlib.gridspec

fig = plt.figure()
G = gridspec.GridSpec(3, 2)

ax1 = fig.add_subplot(G[1:2,1])
ax2 = fig.add_subplot(G[1:2,2])
plt.show()
