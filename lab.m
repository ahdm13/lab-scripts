%
% File: lab.m
% Desc: Useful functions for lab calculations
%

% getintersect: Get intersection between to data point curves. x1 and x2 are
% assumed to be ordered.
function pts = getintersect(x1, y1, x2, y2)
	x_lim_lower = max([x1(1), x2(1)])
	x_lim_upper = min([x1(end), x2(end)])
	step = (x_lim_upper - x_lim_lower) / 1000

	% Find number of intersections:
	n_intersect = 0

	diff = interp1(x1, y1, x_lim_lower) - interp1(x2, y2, x_lim_lower)
	sgn = 0
	newsgn = 0
	if     (diff < 0)
		sgn = -1
	elseif (diff > 0)
		sgn = 1
	endif

	for i = 1:1000
		x = x_lim_lower + step * i

		diff = interp1(x1, y1, x) - interp1(x2, y2, x)
		newsgn = 1
		if     (diff < 0)
			newsgn = -1
		elseif (diff > 0)
			newsgn = 1
		endif

		if (newsgn ~= sgn)
			n_intersect = n_intersect + 1
			sgn = newsgn
		endif
	endfor

	% Initialize pts:
	pts = zeros(n_intersect, 2)

	% Obtain pts:
	diff = interp1(x1, y1, x_lim_lower) - interp1(x2, y2, x_lim_lower)
	sgn = 0
	newsgn = 0
	if     (diff < 0)
		sgn = -1
	elseif (diff > 0)
		sgn = 1
	endif

	j = 1
	for i = 1:1000
		x = x_lim_lower + step * i

		diff = interp1(x1, y1, x) - interp1(x2, y2, x)
		newsgn = 1
		if     (diff < 0)
			newsgn = -1
		elseif (diff > 0)
			newsgn = 1
		endif

		if (newsgn ~= sgn)
			pts(j, 1) = x
			pts(j, 2) = interp1(x1, y1, x)
			j = j + 1
			sgn = newsgn
		endif
	endfor
endfunction

% plotgraph: Plot a graph and save it as a jpeg.
function plotgraph(x, y, t, xl, yl, filename)
	plot(x, y)
	title(t)
	xlabel(xl)
	ylabel(yl)
	ax = gca()
	line(get(ax, 'XLim'), [0, 0], 'Color', 'k', 'LineWidth', 1.5) 
	line([0, 0], get(ax, 'YLim'), 'Color', 'k', 'LineWidth', 1.5) 
	grid on
	print(filename, '-djpg')
endfunction

% plotgraph_nsx: Plot a graph and save it as a jpeg. X-axis is unordered.
function plotgraph_nsx(x, y, ogi, t, xl, yl, filename)
	plot(1:length(x), y)
	title(t)
	xlabel(xl)
	ylabel(yl)
	set(gca, 'XTick', 1:length(x))
	set(gca, 'XTickLabel', x)
	ax = gca()
	line(get(ax, 'XLim'), [0, 0], 'Color', 'k', 'LineWidth', 1.5) 
	line([ogi, ogi], get(ax, 'YLim'), 'Color', 'k', 'LineWidth', 1.5) 
	grid on
	print(filename, '-djpg')
endfunction
