% FILE: Thesis_Parameters.m
% PURPOSE: Centralized definitions of physics and control matrices.
% UPDATE: Corrected for realistic Solar Micro-Irrigation Physics.

clear; clc;

%% 1. PHYSICAL CONSTANTS (The "Plant")
% CRITICAL FIX: Scaled down from 1 Acre to a Greenhouse/Small Plot
% 1 Acre (4046 m^2) was too big for a single 20 L/min pump.
Params.Field_Area = 100;           % [m^2] (10m x 10m Plot)
Params.Root_Depth = 0.5;           % [m]
Params.Soil_Porosity = 0.45;       % Saturation limit [theta_sat]
Params.Field_Capacity = 0.30;      % Optimal limit [theta_fc]
Params.Wilting_Point = 0.15;       % Death limit [theta_wp]

% Soil Dynamics: d(theta)/dt = -k*theta + Beta*Q
% Beta = 1 / (Area * Depth)
Params.Vol_Effective = Params.Field_Area * Params.Root_Depth;
Params.Beta = 1 / Params.Vol_Effective;

% CRITICAL FIX: Lowered Drainage for Loam/Clay (Sand drains too fast)
Params.Drainage_Coeff = 1.0e-6;    % Natural decay [1/s]

%% 2. MODERN CONTROL MATRICES (State Space)
% State x: Soil Moisture
% Input u: Flow Rate [m^3/s]
Params.A = -Params.Drainage_Coeff;
Params.B = Params.Beta;
Params.C = 1;
Params.D = 0;

% Stability Check
eigen = eig(Params.A);
if eigen < 0
    fprintf('[System Check] Plant is Stable. Eigenvalue: %.4e\n', eigen);
else
    error('Plant is Unstable! Check drainage coefficient.');
end

%% 3. CONTROLLER TUNING
Params.Theta_Target = 0.85 * Params.Field_Capacity; % Target 25.5% Moisture
Params.Weights.Health = 1000;  % High penalty for dry soil
Params.Weights.Energy = 0.05;  % Low penalty for energy (Solar is cheap)
Params.dt_sim = 900;           % Simulation Step [s] (15 mins)