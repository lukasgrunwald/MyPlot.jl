using MyPlot

x = -pi:0.01:pi
y = @. sin(x)

segments = 100
N = length(x) - 1
Ns = N ÷ segments

fig, ax = plt.subplots()
gradient_line(ax, x, y, "coolwarm_r", 100)
plt.show()
