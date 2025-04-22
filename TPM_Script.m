clear all;
clc
% close all; % Uncomment if you want to close figures on rerun

%% === Parameter Initialization ===========================================
par = zeros(11, 1);
par(1)  = 1.61e-2;     % cs_max_n (mol/cm^3)
par(2)  = 2.39e-2;     % cs_max_p (mol/cm^3)
par(3)  = 2e-12;       % Ds_n (cm^2/s)
par(4)  = 3.7e-12;     % Ds_p (cm^2/s)
par(5)  = 44940;       % as_n (cm^2/cm^3)
par(6)  = 21803;       % as_p (cm^2/cm^3)
par(7)  = 1340;        % k0 (reaction rate constant)
par(8)  = 9;           % Kt (dimensionless)
par(9)  = 10452;       % Area (cm^2)
par(10) = 1.2e-3;      % ce_aver (mol/cm^3)
par(11) = 1e-6;        % Rp (cm)

A = par(9);
Rp = par(11);

%% === Spatial Discretization Settings ====================================
sr = 20;              % Number of radial slices
Farad = 96485;        % Faraday constant (C/mol)

% Electrode thicknesses (cm)
del_n = 50e-4;
del_e = 25.4e-4;
del_p = 36.4e-4;

% Particle radii (cm) and radial step sizes
Rs_p = 1e-4;
delta_r_p = Rs_p / sr;

Rs_n = 1e-4;
delta_r_n = Rs_n / sr;

%% === Extract Parameters for Convenience ================================
cs_max_n = par(1);
cs_max_p = par(2);
Ds_n     = par(3);
Ds_p     = par(4);
as_n     = par(5);
as_p     = par(6);
ce_aver  = par(10);

%% === SOC Initialization ================================================
SOC_p20         = 0;
y0_percent_p    = 0.936;
y100_percent_p  = 0.442;
x0_percent_n    = 0.126;
x100_percent_n  = 0.676;

SOC = linspace(0, 1, 101);

% Mappings for SOC curves
x      = (x100_percent_n - x0_percent_n) * SOC + x0_percent_n;
y      = (y100_percent_p - y0_percent_p) * SOC + y0_percent_p;
x_init = (x100_percent_n - x0_percent_n) * SOC_p20 + x100_percent_n;
y_init = (y100_percent_p - y0_percent_p) * SOC_p20 + y100_percent_p;

% Initial concentrations
cs_init_p = y_init * cs_max_p;
cs_init_n = x_init * cs_max_n;

% Compute initial concentrations using SOC_p20
cs_init_p = (SOC_p20 * (y100_percent_p - y0_percent_p) + y0_percent_p) * cs_max_p;
cs_init_n = (SOC_p20 * (x100_percent_n - x0_percent_n) + x0_percent_n) * cs_max_n;

%% Plot Equilibrium Potentials vs SOC ====================================
SOC = 0:0.05:1;

% Define stoichiometries for anode (x) and cathode (y)
x = SOC * (x100_percent_n - x0_percent_n) + x0_percent_n;
y = SOC * (y100_percent_p - y0_percent_p) + y0_percent_p;

% Anode open-circuit potential (U_n)
Un = 8.0029 ...
     + 5.0647 .* x ...
     - 12.578 .* sqrt(x) ...
     - 8.6322e-04 ./ x ...
     + 2.1765e-05 .* x.^(3/2) ...
     - 0.46016 .* exp(15 .* (0.06 - x)) ...
     - 0.55364 .* exp(-2.4326 .* (x - 0.92));

% Cathode open-circuit potential (U_p)
Up = -18.6 .* y.^3 ...
     + 31.1854 .* y.^2 ...
     - 17.9895 .* y ...
     + 7.4810;

% Plot results
figure(1)
subplot(2,1,1);
plot(SOC, Up, 'LineWidth', 1.5);
title('Equilibrium Potential vs SOC (U_p)');
ylabel('U_p (V)');
grid on;

subplot(2,1,2);
plot(SOC, Un, 'LineWidth', 1.5);
title('Equilibrium Potential vs SOC (U_n)');
xlabel('State of Charge (SOC)');
ylabel('U_n (V)');
grid on;

%% === Simulink Run Parameters ===========================================
fin = 3500;
dc  = 0;
st  = 1;
tx  = 10:st:fin;
PA  = 5;    % Pulse Amplitude

[t, xx, yy] = sim('TPM_Model', tx);

%% === Plotting Output ====================================================
tc   = tx;
uout = vout;

figure(2)
plot(t, uout(:,2), 'LineWidth', 1.5); hold on
plot(t, vout(:,3), 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('C_{se}');
title('Surface Concentration vs. Time');
legend('C_{se,p}', 'C_{se,n}');
grid on
hold off
