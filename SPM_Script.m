clear
close all
clc

%% === Parameter Initialization ============================================
par(1)  = 1.61e-2;    % cs_max_n
par(2)  = 2.39e-2;    % cs_max_p 
par(3)  = 2e-12;      % Ds_n
par(4)  = 3.7e-12;    % Ds_p
par(5)  = 44940;      % as_n
par(6)  = 21803;      % as_p
par(7)  = 1340;       % k0
par(8)  = 9;          % Kt
par(9)  = 10452;      % Area
par(10) = 1.2e-3;     % ce_aver

%% === Spatial Discretization =============================================
sr = 20;              % Number of radial slices
Farad = 96478;        % Faraday constant (C/mol)

% Electrode thickness (cm)
del_n = 50e-4;
del_e = 25.4e-4;
del_p = 36.4e-4;

% Particle radii and deltas
Rs_p = 1e-4;
delta_r_p = Rs_p / sr;

Rs_n = 1e-4;
delta_r_n = Rs_n / sr;

% Extracted parameters
cs_max_n = par(1);
cs_max_p = par(2);
ce_aver  = par(10);
Ds_n     = par(3);
Ds_p     = par(4);
as_n     = par(5);
as_p     = par(6);

%% === SOC Setup ==========================================================
SOC_p20 = 0;
y0_percent_p    = 0.936;
y100_percent_p  = 0.442;
x0_percent_n    = 0.126;
x100_percent_n  = 0.676;

SOC = linspace(0, 1, 101);

x = (x100_percent_n - x0_percent_n) .* SOC + x0_percent_n;
y = (y100_percent_p - y0_percent_p) .* SOC + y0_percent_p;

x_init = (x100_percent_n - x0_percent_n) * SOC_p20 + x100_percent_n;
y_init = (y100_percent_p - y0_percent_p) * SOC_p20 + y100_percent_p;

cs_init_p = y_init * cs_max_p;
cs_init_n = x_init * cs_max_n;

A = par(9);

%% === Equilibrium Potentials =============================================
U_n = 8.00229 ...
    + 5.0647 .* x ...
    - 12.578 .* sqrt(x) ...
    - 8.6322e-4 ./ x ...
    + 2.1765e-5 .* x.^(1.5) ...
    - 0.46016 .* exp(15 .* (0.06 - x)) ...
    - 0.55364 .* exp(-2.4326 .* (x - 0.92));

U_p = 85.681 .* y.^6 ...
    - 357.7 .* y.^5 ...
    + 613.89 .* y.^4 ...
    - 555.65 .* y.^3 ...
    + 281.06 .* y.^2 ...
    - 76.648 .* y ...
    - 0.30987 .* exp(5.657 .* y.^115) ...
    + 13.1983;

figure(1)
subplot(2,1,1);
plot(SOC, U_n);
ylabel('U_n (V)');
xlabel('SOC');
title('Negative Equilibrium Potential vs SOC');

subplot(2,1,2);
plot(SOC, U_p);
ylabel('U_p (V)');
xlabel('SOC');
title('Positive Equilibrium Potential vs SOC');

%% === Matrix (State-Space) Formulation ===================================
num = sr - 1;

% Build diffusion matrix
diags    = -2 * diag(ones(1, num));
diags_1  = diag(ones(num - 1, 1), 1);
diags_2  = diag(ones(num - 1, 1), -1);
a_setup  = diags + diags_1 + diags_2;

for w = 1:num-1
    a_setup(w, w+1) = (w+1) / w;
end
for g = 2:num-1
    a_setup(g, g-1) = (g-1) / g;
end
a_setup(num, num-1) = (num-2) / (num-1);
a_setup(num, num)   = -1 * (num-2) / (num-1);

% Coefficients
alpha1_n = Ds_n / (delta_r_n^2);
alpha2_n = 1 / (as_n * Farad * delta_r_n);
alpha1_p = Ds_p / (delta_r_p^2);
alpha2_p = 1 / (as_p * Farad * delta_r_p);

% Anode system matrices
Asys_n  = alpha1_n * a_setup;
Bsys_n  = alpha2_n * [zeros(num-1,1); -sr / (sr - 1)];
Csys_n  = [zeros(1, num-1), 1];
Dsys_n  = -alpha2_n / alpha1_n;

% Cathode system matrices
Asys_p  = alpha1_p * a_setup;
Bsys_p  = alpha2_p * [zeros(num-1,1); -sr / (sr - 1)];
Csys_p  = [zeros(1, num-1), 1];
Dsys_p  = -alpha2_p / alpha1_p;

%% === Simulation Settings ================================================
fin = 4500;
dc  = 0;
st  = 1;
tx  = 10:st:fin;
PA  = 5;  % Pulse Amplitude

[t, xx, yy] = sim('SPM_Model', tx);

%% === Plotting Routine ===================================================
tc = tx;
uout = vout;

% figure(8) movie plotting (if enabled)
% if (~dc)
%     figure(8);
%     r = subplot(2,2,1);
%     plot(csn(1,:));
%     set(gca, 'nextplot', 'replacechildren');
%     
%     s = subplot(2,2,2);
%     plot(csp(1,:));
%     set(gca, 'nextplot', 'replacechildren');
%     
%     tpl = subplot(2,2,[3 4]);
%     hold on;
%     plot(t, V);
%     hold off;
%     set(gca, 'nextplot', 'replacechildren');
%     
%     xx = 10;
%     for jdx = 1:xx:length(csn)
%         axes(r); 
%         plot([-(num):1:(num)], [csen(jdx), fliplr(csn(jdx,2:end)), csn(jdx,:), csen(jdx)], 'rd');
%         axis([-sr-1 sr+1 min(csen(:)) max(csn(:))]);
%         xlabel('Particle Slice (1 to M_r)');
%         ylabel('Cs_n');
%         title('Negative Concentration of the Solid');
%         
%         axes(s);
%         plot([-(num):1:(num)], [csep(jdx), fliplr(csp(jdx,2:end)), csp(jdx,:), csep(jdx)], 'bd');
%         axis([-sr-1 sr+1 min(csep(:)) max(csp(:))]);
%         xlabel('Particle Slice (1 to M_r)');
%         ylabel('Cs_p');
%         title('Positive Concentration of the Solid');
%         
%         axes(tpl);
%         plot([st*jdx, st*jdx], [min(V(:)), max(V(:))], '-k', 'LineWidth', 4);
%         axis([-0.01 (st+0.01)*length(csn) min(V(:)) max(V(:))]);
%         hold on;
%         plot(t, V);
%         xlabel('Time (s)');
%         ylabel('Voltage');
%         hold off;
%         F(jdx) = getframe(gcf);
%         pause(0.1333);
%     end
% end

% Final concentration plots
figure(2)
plot(t, csep, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('c_{se,p}');
title('Lithium Concentration at Positive Electrode');
grid on;

figure(3)
plot(t, csen, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('c_{se,n}');
title('Lithium Concentration at Negative Electrode');
grid on;
