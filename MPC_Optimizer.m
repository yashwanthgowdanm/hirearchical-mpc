function [Q_ref_opt, J_min] = MPC_Optimizer(State_Curr, Env_Curr, Params)
    % FILE: MPC_Optimizer.m
    % PURPOSE: Solves J = w1(Error)^2 + w2(Energy) to find Q_ref
    
    % 1. Extract Inputs
    Theta = State_Curr;
    G = Env_Curr.Solar;
    Rain = Env_Curr.Rain;
    ET0 = Env_Curr.ET0;
    
    % 2. Rain Override (The "Smart" Logic)
    if Rain > 0.5
        Q_ref_opt = 0;
        J_min = 0;
        return;
    end
    
    % 3. Crop Demand Lookup (Maize Mid-Season)
    Kc = 1.2;
    ETc = ET0 * Kc;
    
    % 4. Optimization Loop (Brute Force Search 0-20 L/min)
    % Why Brute Force? Because the search space is small and non-linear.
    Possible_Flows = linspace(0, 20, 21); % [L/min]
    J_min = inf;
    Q_ref_opt = 0;
    
    for Q_test = Possible_Flows
        % Convert to SI [m^3/s]
        Q_m3s = Q_test / 60000;
        
        % Predict Next State (Using discretized Physics Equation)
        % theta(k+1) = theta(k) + dt * (Inputs - Outputs)
        Theta_Next = Theta + Params.dt_sim * ...
            (Params.Beta*Q_m3s - Params.Beta*ETc - Params.Drainage_Coeff*Theta);
        
        % Cost 1: Health (Distance from Target)
        J_health = (Params.Theta_Target - Theta_Next)^2;
        
        % Cost 2: Energy Efficiency
        % Price is High if Solar is Low. Price is Low if Solar is High.
        Price_Index = 1 / (G + 10); 
        J_energy = Price_Index * Q_test;
        
        % Total Cost
        J_total = Params.Weights.Health * J_health + ...
                  Params.Weights.Energy * J_energy;
              
        if J_total < J_min
            J_min = J_total;
            Q_ref_opt = Q_test;
        end
    end
end