% FILE: Run_Simulation_Main.m
% PURPOSE: Orchestrates the simulation and generates thesis plots.

% 1. Load Parameters
Thesis_Parameters; 

% 2. Generate Environment
T_Sim_Hours = 24;
Env = Thesis_Weather_Gen(T_Sim_Hours*3600, Params.dt_sim);
N = length(Env.Time);

% 3. Pre-allocate Storage Vectors
Rec_MPC.Theta = zeros(1,N); Rec_MPC.Theta(1) = 0.20; % Start Dry
Rec_MPC.Flow = zeros(1,N);
Rec_MPC.Energy = 0;

Rec_Std.Theta = zeros(1,N); Rec_Std.Theta(1) = 0.20;
Rec_Std.Flow = zeros(1,N);
Rec_Std.Energy = 0;

fprintf('Simulation Started... ');

%% 4. MAIN SIMULATION LOOP
for k = 1:N-1
    % --- Current Environment Slice ---
    Env_Slice.Solar = Env.Solar(k);
    Env_Slice.Rain = Env.Rain(k);
    Env_Slice.ET0 = Env.ET0(k);
    
    % --- CONTROLLER A: HIERARCHICAL MPC (The Thesis) ---
    [Q_cmd, ~] = MPC_Optimizer(Rec_MPC.Theta(k), Env_Slice, Params);
    
    % Inner Loop Simulation (Voltage Constraint)
    % If Voltage < 12V (approx < 100 W/m^2), Pump Stalls
    if Env.Solar(k) < 100
        Q_actual_MPC = 0; 
    else
        Q_actual_MPC = Q_cmd; % Assumed Perfect Tracking by MAE 506 Controller
    end
    Rec_MPC.Flow(k) = Q_actual_MPC;
    
    % Update MPC Plant Physics
    Q_in = Q_actual_MPC / 60000;
    Rain_in = (Env.Rain(k) * 1e-3 * Params.Field_Area) / 3600;
    ET_out = Env.ET0(k) * 1.2; % Kc=1.2
    
    dTheta = Params.Beta*(Q_in + Rain_in - ET_out) - Params.Drainage_Coeff*Rec_MPC.Theta(k);
    Rec_MPC.Theta(k+1) = Rec_MPC.Theta(k) + dTheta * Params.dt_sim;
    
    % Energy Accumulation (Integration)
    if Q_actual_MPC > 0
        Rec_MPC.Energy = Rec_MPC.Energy + (150 * Params.dt_sim); % Assume 150W pump
    end
    
    % --- CONTROLLER B: STANDARD TIMER (The Strawman) ---
    % ON between 9 AM and 5 PM
    if Env.Time_Hrs(k) >= 9 && Env.Time_Hrs(k) <= 17
        Q_std = 15; % Constant 15 L/min
    else
        Q_std = 0;
    end
    Rec_Std.Flow(k) = Q_std;
    
    % Update Standard Plant Physics
    Q_in_std = Q_std / 60000;
    dTheta_std = Params.Beta*(Q_in_std + Rain_in - ET_out) - Params.Drainage_Coeff*Rec_Std.Theta(k);
    Rec_Std.Theta(k+1) = Rec_Std.Theta(k) + dTheta_std * Params.dt_sim;
    
    if Q_std > 0
        Rec_Std.Energy = Rec_Std.Energy + (150 * Params.dt_sim);
    end
end

fprintf('Done.\n');

%% 5. VISUALIZATION
figure('Name', 'Thesis Results', 'Color', 'w', 'Position', [100 100 1200 800]);

% Plot 1: Weather
subplot(3,1,1);
yyaxis left; area(Env.Time_Hrs, Env.Solar, 'FaceColor', [1 0.9 0.6], 'EdgeColor', 'none'); 
ylabel('Solar [W/m^2]'); ylim([0 1000]);
yyaxis right; bar(Env.Time_Hrs, Env.Rain, 0.4, 'b'); ylabel('Rain [mm/hr]');
title('A. Environmental Disturbances (Input D)'); legend('Solar', 'Rain'); grid on;

% Plot 2: Control Effort
subplot(3,1,2);
plot(Env.Time_Hrs, Rec_Std.Flow, 'k--', 'LineWidth', 1.5); hold on;
plot(Env.Time_Hrs, Rec_MPC.Flow, 'g-', 'LineWidth', 2.5);
ylabel('Flow Rate [L/min]'); legend('Standard Timer', 'Proposed MPC');
title('B. Control Effort (Input U)'); grid on;
text(14.2, 5, 'MPC reacts to Rain \rightarrow', 'Color', 'b', 'FontWeight', 'bold');

% Plot 3: Soil State
subplot(3,1,3);
plot(Env.Time_Hrs, Rec_Std.Theta*100, 'k--', 'LineWidth', 1.5); hold on;
plot(Env.Time_Hrs, Rec_MPC.Theta*100, 'b-', 'LineWidth', 2.5);
yline(Params.Theta_Target*100, 'g--', 'Optimal Target');
yline(Params.Wilting_Point*100, 'r-', 'Wilting Point (Death)');
ylabel('Soil Moisture [%]'); xlabel('Time [Hours]');
title('C. System State Response (Output Y)'); legend('Standard', 'Proposed MPC');
grid on; ylim([15 35]);

%% 6. QUANTITATIVE METRICS
Water_Saved = sum(Rec_Std.Flow - Rec_MPC.Flow) * Params.dt_sim / 60;
Energy_Saved = (Rec_Std.Energy - Rec_MPC.Energy) / 3600; % Wh

fprintf('\n--- FINAL THESIS RESULTS ---\n');
fprintf('1. Water Saved: %.2f Liters\n', Water_Saved);
fprintf('2. Energy Saved: %.2f Wh\n', Energy_Saved);
fprintf('----------------------------\n');