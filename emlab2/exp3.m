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

% Plot (Revision 2)
% ------------------
plotgraph(occ_x_r2, occ_y_r2, 'Open Circuit Characteristics', 'I_F (A)', ...
	'V_{OC} (V)', 'occ_r2.jpg')
plotgraph(scc_x_r2, scc_y_r2, 'Short Circuit Characteristics', 'I_F (A)', ...
	'I_{SC} (A)', 'scc_r2.jpg')
plotgraph(zpf_x_r2, zpf_y_r2, 'Zero Power Factor Curve (I_A = 5A)', ...
	'I_F (A)', 'V (V)', 'zpf_r2.jpg')


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
resistance = resistance_v ./ resistance_i
resistance_dc = mean(resistance)
r_a  = resistance_dc * 1.2

% Z_S
% ------------------
z_s_i_f = interp1(occ_y, occ_x, v_rated, 'linear', 'extrap')
z_s_i_sc = interp1(scc_x, scc_y, z_s_i_f, 'linear', 'extrap')
z_s = v_rated / z_s_i_sc

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
	vr = 100 .* (e - v) ./ v
endfunction

% Full Load
% ------------------
e_fl_emf = e_emf(v_rated, i_rated, r_a, x_s, pf, leadlag)
vr_fl_emf = vr_percent_emf(v_rated, i_rated, r_a, x_s, pf, leadlag)
plotgraph_nsx(pf, vr_fl_emf, 4, 'Voltage Regulation (EMF Method, Full Load)', ...
	'PF', 'VR (%)', 'vr_fl_emf.jpg')

% Half Load
% ------------------
e_hl_emf = e_emf(v_rated, i_rated/2, r_a, x_s, pf, leadlag)
vr_hl_emf = vr_percent_emf(v_rated, i_rated/2, r_a, x_s, pf, leadlag)
plotgraph_nsx(pf, vr_hl_emf, 4, 'Voltage Regulation (EMF Method, Half Load)', ...
	'PF', 'VR (%)', 'vr_hl_emf.jpg')

% ==============================================================================
% Computation of Voltage regulation (MMF Method)
% ==============================================================================

% i_f_mmf: Get I_F from I_F1 and I_F2
function i_f = i_f_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	i_f1 = interp1(occ_y, occ_x, v, 'linear', 'extrap')
	i_f2 = interp1(scc_y, scc_x, i, 'linear', 'extrap')
	cosphi = pf
	sinphi = leadlag .* sqrt(1 - (pf .^ 2))
	i_f = sqrt(((i_f1 + (i_f2 .* sinphi)) .^ 2) + ((i_f2 .* cosphi)))
endfunction

% e_emf: OC voltage from MMF method
function e = e_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	i_f = i_f_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	e = interp1(occ_x, occ_y, i_f, 'linear', 'extrap')
endfunction

% vr_percent_mmf: Percentage voltage regulation from mmf method
function vr = vr_percent_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	e = e_mmf(v, i, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
	vr = 100 .* (e - v) ./ v
endfunction

% Full Load
% ------------------
e_fl_mmf = e_mmf(v_rated, i_rated, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
vr_fl_mmf = vr_percent_mmf(v_rated, i_rated, occ_x, occ_y, scc_x, scc_y, pf, ...
	leadlag)
plotgraph_nsx(pf, vr_fl_mmf, 4, 'Voltage Regulation (MMF Method, Full Load)', ...
	'PF', 'VR (%)', 'vr_fl_mmf.jpg')

% Half Load
% ------------------
e_hl_mmf = e_mmf(v_rated, i_rated/2, occ_x, occ_y, scc_x, scc_y, pf, leadlag)
vr_hl_mmf = vr_percent_mmf(v_rated, i_rated/2, occ_x, occ_y, scc_x, scc_y, ...
	pf, leadlag)
plotgraph_nsx(pf, vr_hl_mmf, 4, 'Voltage Regulation (MMF Method, Half Load)', ...
	'PF', 'VR (%)', 'vr_hl_mmf.jpg')

% ==============================================================================
% Computation of Voltage regulation (ZPF Method)
% ==============================================================================

function e_i = e_i_zpf(v, i, r_a, x_l, pf, leadlag)
	cosphi = pf
	sinphi = leadlag .* sqrt(1 - (pf .^ 2))
	e_i_squared = (((v .* cosphi) + (i .* r_a)) .^ 2) + ...
		(((v .* sinphi) + (i .* x_l)) .^ 2)
	e_i = sqrt(e_i_squared)
endfunction

function i_f1 = i_f1_zpf(v, i, occ_x, occ_y, r_a, x_l, pf, leadlag)
	e_i = e_i_zpf(v, i, r_a, x_l, pf, leadlag)
	i_f1 = interp1(occ_y, occ_x, e_i, 'linear', 'extrap')
endfunction

function i_f = i_f_zpf(v, i, i_f2, occ_x, occ_y, r_a, x_l, pf, leadlag)
	cosphi = pf
	sinphi = leadlag .* sqrt(1 - (pf .^ 2))
	i_f1 = i_f1_zpf(v, i, occ_x, occ_y, r_a, x_l, pf, leadlag)
	i_f = sqrt(((i_f1 + (i_f2 .* sinphi)) .^ 2) + (i_f2 .* cosphi))
endfunction

function e = e_zpf(v, i, i_f2, occ_x, occ_y, r_a, x_l, pf, leadlag)
	i_f = i_f_zpf(v, i, i_f2, occ_x, occ_y, r_a, x_l, pf, leadlag)
	e = interp1(occ_x, occ_y, i_f, 'linear', 'extrap')
endfunction

function vr = vr_percent_zpf(v, i, i_f2, occ_x, occ_y, r_a, x_l, pf, leadlag)
	e = e_zpf(v, i, i_f2, occ_x, occ_y, r_a, x_l, pf, leadlag)
	vr = 100 * (e - v) ./ v
endfunction

% Full Load
% ------------------
e_i_fl_zpf = e_i_zpf(v_rated, i_rated, r_a, x_l, pf, leadlag)
e_fl_zpf = e_zpf(v_rated, i_rated, i_f2_zpf, occ_x, occ_y, r_a, x_l, pf, leadlag)
i_f1_fl_zpf = i_f1_zpf(v_rated, i_rated, occ_x, occ_y, r_a, x_l, pf, leadlag)
i_f_fl_zpf = i_f_zpf(v_rated, i_rated, i_f2_zpf, occ_x, occ_y, r_a, x_l, pf, leadlag)
vr_fl_zpf = vr_percent_zpf(v_rated, i_rated, i_f2_zpf, occ_x, occ_y, r_a, x_l, pf, ...
	leadlag)
plotgraph_nsx(pf, vr_fl_zpf, 4, 'Voltage Regulation (ZPF Method, Full Load)', ...
	'PF', 'VR (%)', 'vr_fl_zpf.jpg')

% Half Load
% ------------------
e_i_hl_zpf = e_i_zpf(v_rated, i_rated/2, r_a, x_l, pf, leadlag)
e_hl_zpf = e_zpf(v_rated, i_rated/2, i_f2_zpf, occ_x, occ_y, r_a, x_l, pf, leadlag)
i_f1_hl_zpf = i_f1_zpf(v_rated, i_rated/2, occ_x, occ_y, r_a, x_l, pf, leadlag)
i_f_hl_zpf = i_f_zpf(v_rated, i_rated/2, i_f2_zpf, occ_x, occ_y, r_a, x_l, pf, leadlag)
vr_hl_zpf = vr_percent_zpf(v_rated, i_rated/2, i_f2_zpf, occ_x, occ_y, r_a, x_l, ...
	pf, leadlag)
plotgraph_nsx(pf, vr_hl_zpf, 4, 'Voltage Regulation (ZPF Method, Half Load)', ...
	'PF', 'VR (%)', 'vr_hl_zpf.jpg')

% ==============================================================================
% Direct loading
% ==============================================================================
e_hl_dir = sqrt(((direct_loading_v(1) + (direct_loading_i(1) * r_a)) ^ 2) + ((direct_loading_i(1) * x_s) ^ 2))
vr_hl_dir = 100 * (e_hl_dir - direct_loading_v(1)) / direct_loading_v(1)
e_fl_dir = sqrt(((direct_loading_v(2) + (direct_loading_i(2) * r_a)) ^ 2) + ((direct_loading_i(2) * x_s) ^ 2))
vr_fl_dir = 100 * (e_fl_dir - direct_loading_v(2)) / direct_loading_v(2)

% ==============================================================================
% Print tables
% ==============================================================================

% Resistance Measurement
% ------------------
printf("\n")
printf("Resistance Measurement\n")
printf("======================\n")
printf("|--------------------------|\n")
printf("|V (V)   |I (A)   |R (Ohms)|\n")
printf("|--------|--------|--------|\n")
for i = 1:length(resistance)
	printf("|%-8.2f|%-8.2f|%-8.2f|\n", resistance_v(i), resistance_i(i), resistance(i))
endfor
printf("|--------------------------|\n")
printf("R_mean = %.2f\n", resistance_dc)
printf("R_ac = R_mean * 1.2 = %.2f\n", r_a)
printf("\n")

% OCC
% ------------------
printf("\n")
printf("Open Circuit Characteristics\n")
printf("============================\n")
printf("|-----------------|\n")
printf("|I_F (A) |V_OC (V)|\n")
printf("|--------|--------|\n")
for i = 1:length(occ_x_r1)
	printf("|%-8.2f|%-8.2f|\n", occ_x_r1(i), occ_y_r2(i))
endfor
printf("|-----------------|\n")
printf("\n")

% SCC
% ------------------
printf("\n")
printf("Short Circuit Characteristics\n")
printf("=============================\n")
printf("|-----------------|\n")
printf("|I_F (A) |I_SC (A)|\n")
printf("|--------|--------|\n")
for i = 1:length(scc_x)
	printf("|%-8.2f|%-8.2f|\n", scc_x(i), scc_y(i))
endfor
printf("|-----------------|\n")
printf("\n")

% ZPF
% ------------------
printf("\n")
printf("Zero Power Factor Curve (I_A = 5A)\n")
printf("==================================\n")
printf("|---------------|\n")
printf("|I_F (A)|V (V)  |\n")
printf("|-------|-------|\n")
for i = 1:length(zpf_x)
	printf("|%-7.2f|%-7.2f|\n", zpf_x(i), zpf_y(i))
endfor
printf("|---------------|\n")
printf("\n")

% Direct loading
% ------------------
printf("\n")
printf("Direct Loadng\n")
printf("=============\n")
printf("|-------------|\n")
printf("|I (A) |V (V) |\n")
printf("|------|------|\n")
printf("|%-6.2f|%-6.2f|\n", direct_loading_i(1), direct_loading_v(1))
printf("|%-6.2f|%-6.2f|\n", direct_loading_i(2), direct_loading_v(2))
printf("|-------------|\n")
printf("\n")

% Voltage Regulation
% ------------------
printf("\n")
printf("Voltage Regulation\n")
printf("==================\n")
printf("|------------------------------------------------------------------------------------------------------------------------------------|\n")
printf("|Power Factor|Voltage|EMF Method                 |MMF Method                 |ZPF Method                 |Direct Loading             |\n")
printf("|            |       |---------------------------|---------------------------|---------------------------|---------------------------|\n")
printf("|            |       |Full Load    |Half Load    |Full Load    |Half Load    |Full Load    |Half Load    |Full Load    |Half Load    |\n")
printf("|            |       |-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|\n")
printf("|            |       |E (V) |VR (%%)|E (V) |VR (%%)|E (V) |VR (%%)|E (V) |VR (%%)|E (V) |VR (%%)|E (V) |VR (%%)|E (V) |VR (%%)|E (V) |VR (%%)|\n")
printf("|------------|-------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|\n")
printf("|0.2 lag     |%-6.2f |%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|      |      |      |      |\n", v_rated, e_fl_emf(7), vr_fl_emf(7), e_hl_emf(7), vr_hl_emf(7), e_fl_mmf(7), vr_fl_mmf(7), e_hl_mmf(7), vr_hl_mmf(7), e_fl_zpf(7), vr_fl_zpf(7), e_hl_zpf(7), vr_hl_zpf(7))
printf("|0.5 lag     |%-6.2f |%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|      |      |      |      |\n", v_rated, e_fl_emf(6), vr_fl_emf(6), e_hl_emf(6), vr_hl_emf(6), e_fl_mmf(6), vr_fl_mmf(6), e_hl_mmf(6), vr_hl_mmf(6), e_fl_zpf(6), vr_fl_zpf(6), e_hl_zpf(6), vr_hl_zpf(6))
printf("|0.8 lag     |%-6.2f |%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|      |      |      |      |\n", v_rated, e_fl_emf(5), vr_fl_emf(5), e_hl_emf(5), vr_hl_emf(5), e_fl_mmf(5), vr_fl_mmf(5), e_hl_mmf(5), vr_hl_mmf(5), e_fl_zpf(5), vr_fl_zpf(5), e_hl_zpf(5), vr_hl_zpf(5))
printf("|------------|-------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|\n")
printf("|1.0 unity   |%-6.2f |%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|\n", v_rated, e_fl_emf(4), vr_fl_emf(4), e_hl_emf(4), vr_hl_emf(4), e_fl_mmf(4), vr_fl_mmf(4), e_hl_mmf(4), vr_hl_mmf(4), e_fl_zpf(4), vr_fl_zpf(4), e_hl_zpf(4), vr_hl_zpf(4), e_fl_dir, vr_fl_dir, e_hl_dir, vr_hl_dir)
printf("|------------|-------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|------|\n")
printf("|0.8 lead    |%-6.2f |%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|      |      |      |      |\n", v_rated, e_fl_emf(3), vr_fl_emf(3), e_hl_emf(3), vr_hl_emf(3), e_fl_mmf(3), vr_fl_mmf(3), e_hl_mmf(3), vr_hl_mmf(3), e_fl_zpf(3), vr_fl_zpf(3), e_hl_zpf(3), vr_hl_zpf(3))
printf("|0.5 lead    |%-6.2f |%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|      |      |      |      |\n", v_rated, e_fl_emf(2), vr_fl_emf(2), e_hl_emf(2), vr_hl_emf(2), e_fl_mmf(2), vr_fl_mmf(2), e_hl_mmf(2), vr_hl_mmf(2), e_fl_zpf(2), vr_fl_zpf(2), e_hl_zpf(2), vr_hl_zpf(2))
printf("|0.2 lead    |%-6.2f |%-6.2f|%-6.1f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|%-6.2f|      |      |      |      |\n", v_rated, e_fl_emf(1), vr_fl_emf(1), e_hl_emf(1), vr_hl_emf(1), e_fl_mmf(1), vr_fl_mmf(1), e_hl_mmf(1), vr_hl_mmf(1), e_fl_zpf(1), vr_fl_zpf(1), e_hl_zpf(1), vr_hl_zpf(1))
printf("|------------------------------------------------------------------------------------------------------------------------------------|\n")
printf("\n")
