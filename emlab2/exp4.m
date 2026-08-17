%
% Experiment 4
% Predetermination of voltage regulation using slip test
%

clear

source("lab.m")
source("data.m")

% ==============================================================================
% Values assumed

v_rated = 230
i_rated = 11.6

v_max   = v_max_orig
v_min   = v_min_orig
i_max   = i_max_orig
i_min   = i_min_orig

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

% X_d
% ------------------
z_d = v_max / i_min
x_d = sqrt((z_d ^ 2) - (r_a ^2))

% X_q
% ------------------
z_q = v_min / i_max
x_q = sqrt((z_q ^ 2) - (r_a ^2))

% ==============================================================================
% Computation of Voltage regulation using slip test:
% ==============================================================================

% power_angle: Get power angle for different loading conditions by using
% intermediate emf.
function del = power_angle(v, i, r_a, x_q, pf, leadlag)
	cosphi = pf
	sinphi = -leadlag .* sqrt(1 - (cosphi .^ 2))
	arg_i = cosphi + (j * sinphi)
	e_i = v + (i * arg_i * r_a) + (i * arg_i * j * x_q)
	del = arg(e_i)
endfunction

function e = e(v, i, r_a, x_d, x_q, pf, leadlag)
	del = power_angle(v, i, r_a, x_q, pf, leadlag)

	cosphi = pf
	sinphi = -leadlag .* sqrt(1 - (cosphi .^ 2))
	phi = asin(sinphi)

	i_d = i * sin(-phi + del)
	i_q = i * cos(-phi + del)

	arg_i = cosphi + (j * sinphi)
	arg_i_d = cos((pi/2) - del) - (j * sin((pi/2) - del))
	arg_i_q = cos(del) + (j * sin(del))

	e_complex = v + (i * arg_i * r_a) + (j * i_d .* arg_i_d * x_d) + (j * i_q .* arg_i_q * x_q)
	e = abs(e_complex)
endfunction

function vr = vr_percent(v, i, r_a, x_d, x_q, pf, leadlag)
	e = e(v, i, r_a, x_d, x_q, pf, leadlag)
	vr = 100 * (e - v) ./ v
endfunction

% At full load:
del_fl = power_angle(v_rated, i_rated, r_a, x_q, pf, leadlag) * (180 / pi)
e_fl = e(v_rated, i_rated, r_a, x_d, x_q, pf, leadlag)
vr_fl = vr_percent(v_rated, i_rated, r_a, x_d, x_q, pf, leadlag)

% At half load:
del_hl = power_angle(v_rated, i_rated/2, r_a, x_q, pf, leadlag) * (180 / pi)
e_hl = e(v_rated, i_rated/2, r_a, x_d, x_q, pf, leadlag)
vr_hl = vr_percent(v_rated, i_rated/2, r_a, x_d, x_q, pf, leadlag)

% Plot voltage regulation curves:
[p1, xp1, yp1] = plotgraph_nsx(pf, vr_hl, 4, 'Voltage Regulation (Slip test)', ...
	'PF', 'VR (%)')
hold on
[p2, xp2, yp2] = plotgraph_nsx(pf, vr_fl, 4, 'Voltage Regulation (Slip test)', ...
	'PF', 'VR (%)')
hold off
legend([p1, p2], {'Half Load', 'Full Load'})
savegraph('vr.jpg')

% ==============================================================================
% Print tables
% ==============================================================================

% Slip test:
printf('\nSlip Test\n')
state = table_start({'V_max (V)', 'V_min (V)', 'I_max (A)', 'I_min (A)', 'Z_d (Ohms)', 'Z_q (Ohms)', 'X_d (Ohms)', 'X_q (Ohms)'}, 10, zeros(1, 8), zeros(1, 8));
state = table_row_data(state, [ v_max, v_min, i_max, i_min, z_d, z_q, x_d, x_q ], 10, 3, zeros(1, 8), zeros(1, 8));
table_end(state, 8, 10);

% Stator resistance:
printf('\nStator Winding Resistance\n')
state = table_start({'V (V)', 'I (A)', 'R (Ohms)'}, 10, zeros(1, 3), zeros(1, 3));
for i = 1:length(resistance)
	state = table_row_data(state, [ resistance_v(i), resistance_i(i), resistance(i) ], 10, 2, zeros(1, 3), zeros(1, 3));
endfor
table_end(state, 3, 10);
printf('R_mean = %-0.2f, R_a = %-0.2f\n', resistance_dc, r_a);

% Predetermination:
printf('\nPredetermination of Voltage Regulation\n')
state = table_start({ '', 'PF', 'V (V)', 'Full Load', '', 'Half Load', '' }, 10, [ 1, 1, 1, 0, 0, 0, 0 ], [ 1, 0, 0, 1, 0, 1, 0 ]);
state = table_row(state, { '', '', '', 'E_0 (V)', 'VR (%)', 'E_0 (V)', 'VR (%)'}, 10, zeros(1, 7), [ 1, 0, 0, 1, 0, 1, 0 ]);

nlead = 3;
nlag = 3;

for i = length(pf):-1:1
	if (i == length(pf) - nlag + 1 || i == length(pf) - nlag || i == 1)
		mrow = [ 0, 0, 0, 0, 0, 0, 0 ];
	else
		mrow = [ 1, 1, 1, 1, 1, 1, 1 ];
	endif
	mcol = [ 1, 0, 0, 1, 0, 1, 0 ];

	if (i == length(pf))
		label = 'lag';
	elseif (i == length(pf) - nlag)
		label = 'unity';
	elseif (i == length(pf) - nlag - 1)
		label = 'lead';
	else
		label = '';
	endif

	state = table_row(state, { label, num2str(pf(i)), num2str(v_rated), num2str(e_fl(i)), num2str(vr_fl(i)), num2str(e_hl(i)), num2str(vr_hl(i)) }, 10, ...
		mrow, mcol);
endfor
table_end(state, 7, 10);
