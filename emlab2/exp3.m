clear

source("lab.m")
source("data.m")

% ==============================================================================

% Plot (Original)
% ------------------
plotgraph(occ_x_orig, occ_y_orig, 'Open Circuit Characteristics', 'I_F (A)', ...
	'V_{OC} (V)', 'occ_orig.jpg')
plotgraph(scc_x_orig, scc_y_orig, 'Short Circuit Characteristics', ...
	'I_F (A)', 'I_{SC} (A)', 'scc_orig.jpg')
plotgraph(zpf_x_orig, zpf_y_orig, 'Zero Power Factor Curve (I_A = 5A)', ...
	'I_F (A)', 'V (V)', 'zpf_orig.jpg')

% Plot (Revision 1)
% ------------------
plotgraph(occ_x_r1, occ_y_r1, 'Open Circuit Characteristics', 'I_F (A)', ...
	'V_{OC} (V)', 'occ_r1.jpg')
plotgraph(scc_x_r1, scc_y_r1, 'Short Circuit Characteristics', 'I_F (A)', ...
	'I_{SC} (A)', 'scc_r1.jpg')
plotgraph(zpf_x_r1, zpf_y_r1, 'Zero Power Factor Curve (I_A = 5A)', ...
	'I_F (A)', 'V (V)', 'zpf_r1.jpg')

% ==============================================================================
% Values assumed

v_rated = 230
i_rated = 6.3

occ_x   = occ_x_r2
occ_y   = occ_y_r2

scc_x   = scc_x_r2
scc_y   = scc_y_r2

zpf_x   = zpf_x_r2
zpf_y   = zpf_y_r2
zpf_i   = zpf_i_r2

% Preset power factor values:
pf      = [ 0.2, 0.5, 0.8, 1, 0.8, 0.5, 0.2 ]
leadlag = [  -1,  -1,  -1, 0,   1,   1,   1 ]

% ==============================================================================
% Computation of parameters from observations
% ==============================================================================

% R_A
% ------------------
resistance = resistance_v / resistance_i
r_dc = mean(resistance)
r_a  = r_dc * 1.2

clear resistance
clear r_dc

% Z_S
% ------------------
i_f = interp1(occ_y, occ_x, v_rated)
i_sc = interp1(scc_x, scc_y, i_f)
z_s = v_rated / i_f

clear i_f
clear i_sc

% X_S
% ------------------
x_s = sqrt((z_s ^ 2) - (r_a ^ 2))

% ==============================================================================
% Computation of Voltage regulation (EMF Method)
% ==============================================================================

% e_emf: OC volatage from emf method
function e = e_emf(v, i, r_a, x_s, pf, leadlag)
	cosphi = pf
	sinphi = leadlag .* sqrt(1 - (pf .^ 2))
	e_squared = ((v .* cosphi) + (i * r_a)) .^ 2 + ((v .* sinphi) ...
		+ (i * x_s)) .^ 2
	e = sqrt(e_squared)
endfunction

% vr_percent_emf: Percentage voltage regulation from emf method
function vr = vr_percent_emf(v, i, r_a, x_s, pf, leadlag)
	e = e_emf(v, i, r_a, x_s, pf, leadlag)
	vr = 100 .* (e - v) ./ e
endfunction

% Full Load
% ------------------
e_fl_emf = e_emf(v_rated, i_rated, r_a, x_s, pf, leadlag)
vr_fl_emf = vr_percent_emf(v_rated, i_rated, r_a, x_s, pf, leadlag)
plotgraph_nsx(pf, vr_fl_emf, 4, 'Voltage Regulation (EMF Method, Full Load)', ...
	'PF', 'VR (%)', 'vr_fl_emf_r1.jpg')

% Half Load
% ------------------
e_hl_emf = e_emf(v_rated, i_rated/2, r_a, x_s, pf, leadlag)
vr_hl_emf = vr_percent_emf(v_rated, i_rated/2, r_a, x_s, pf, leadlag)
plotgraph_nsx(pf, vr_hl_emf, 4, 'Voltage Regulation (EMF Method, Half Load)', ...
	'PF', 'VR (%)', 'vr_hl_emf_r1.jpg')

% ==============================================================================
% Computation of Voltage regulation (MMF Method)
% ==============================================================================

% i_f_mmf: Get I_F from I_F1 and I_F2
function i_f = i_f_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	i_f1 = interp1(occ_y, occ_x, v)
	i_f2 = interp1(scc_y, scc_x, i)
	cosphi = pf
	sinphi = leadlag .* sqrt(1 - (pf .^ 2))
	i_f = sqrt(((i_f1 + (i_f2 .* sinphi)) .^ 2) + (i_f2 .* cosphi))
endfunction

% e_emf: OC voltage from MMF method
function e = e_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	i_f = i_f_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	e = interp1(occ_x, occ_y, i_f, 'linear', 'extrap')
endfunction

% vr_percent_mmf: Percentage voltage regulation from mmf method
function vr = vr_percent_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	e = e_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	vr = 100 .* (e - v) ./ e
endfunction

% Full Load
% ------------------
e_fl_mmf = e_mmf(v_rated, i_rated, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
vr_fl_mmf = vr_percent_mmf(v_rated, i_rated, occ_x, occ_y, scc_x, scc_y, pf, ...
	leadlag)
plotgraph_nsx(pf, vr_fl_mmf, 4, 'Voltage Regulation (MMF Method, Full Load)', ...
	'PF', 'VR (%)', 'vr_fl_mmf_r1.jpg')

% Half Load
% ------------------
e_hl_mmf = e_mmf(v_rated, i_rated/2, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
vr_hl_mmf = vr_percent_mmf(v_rated, i_rated/2, occ_x, occ_y, scc_x, scc_y, ...
	pf, leadlag)
plotgraph_nsx(pf, vr_hl_mmf, 4, 'Voltage Regulation (MMF Method, Half Load)', ...
	'PF', 'VR (%)', 'vr_hl_mmf_r1.jpg')

% ==============================================================================
% Computation of Voltage regulation (ZPF Method)
% ==============================================================================

% Potier triangle
% ------------------

% Draw ZPFC:
plot(zpf_x, zpf_y)
hold on

% Draw OCC:
plot(occ_x, occ_y)

% Draw tangent to OCC:
tangent_m = ((occ_y(2) - occ_y(1))/(occ_x(2) - occ_x(1)))
tangent_x = 1:7
tangent_y = tangent_m * tangent_x
plot(tangent_x, tangent_y)

% Draw triangle base:
zpf_rated_if = interp1(zpf_y, zpf_x, v_rated)
line([zpf_rated_if - zpf_x(1), zpf_rated_if], [v_rated, v_rated])

% Draw triangle face parallel to occ tangent:
parallel_x = zpf_rated_if - zpf_x(1):26
parallel_y = v_rated + tangent_m * (parallel_x - parallel_x(1))

% Get intersection of parallel line with occ and complete triangle:
intersect = getintersect(parallel_x, parallel_y, occ_x, occ_y)
if (length(intersect) ~= 0)
	line([zpf_rated_if - zpf_x(1), intersect(1, 1)], [v_rated, intersect(1, 2)])
	line([intersect(1, 1), zpf_rated_if], [intersect(1, 2), v_rated])
	line([intersect(1, 1), intersect(1, 1)], [intersect(1, 2), v_rated])
endif

hold off
grid on

clear zpf_rated_if
