function Env = Thesis_Weather_Gen(T_total, dt)
    % FILE: Thesis_Weather_Gen.m
    % PURPOSE: Generates synthetic 24-hr profile for Solar, Temp, Rain
    
    Time = 0:dt:T_total;
    N = length(Time);
    Time_Hrs = Time/3600;
    
    % 1. Solar Profile (Bell Curve with Noise)
    % Peak at 12:00 PM (800 W/m^2)
    G = max(0, 800 * sin(pi * (Time_Hrs - 6)/12)); 
    G(Time_Hrs > 18 | Time_Hrs < 6) = 0; % Night hard clamp
    
    % Add Cloud Noise
    rng(42); 
    Noise = 1 - 0.2*rand(1,N); 
    G = G .* Noise;

    % 2. Temperature Profile
    T_air = 25 + 10 * sin(pi * (Time_Hrs - 9)/12);

    % 3. Rain Scenario
    % Storm at 2:00 PM (14:00)
    Rain = zeros(1,N);
    Rain(Time_Hrs >= 14 & Time_Hrs <= 15) = 5.0; % 5 mm/hr
    G(Time_Hrs >= 14 & Time_Hrs <= 15) = 50; % Clouds block sun
    
    % 4. Calculate ET0 (Reference Evapotranspiration)
    % CRITICAL FIX: Scale to meters/second correctly.
    % 1 mm/hr = 1e-3 m / 3600 s = 2.77e-7 m/s
    % Assumption: 800 W/m^2 Solar ~= 1 mm/hr Evaporation
    Scaling_Factor = (1e-3 / 3600) / 800; 
    ET0 = G * Scaling_Factor; % [m/s]
    
    % 5. Pack into Struct
    Env.Time = Time;
    Env.Time_Hrs = Time_Hrs;
    Env.Solar = G;
    Env.Temp = T_air;
    Env.Rain = Rain;
    Env.ET0 = ET0;
end