# Hierarchical Model Predictive Control (MPC) for Energy-Optimal Autonomous Solar Irrigation Systems

## 🚀 Overview
[cite_start]This project presents a novel **Hierarchical Cyber-Physical Control Architecture** designed to optimize solar-powered irrigation systems in off-grid regions[cite: 3, 6]. 

[cite_start]Standard solar irrigation solutions often suffer from a "Smartness Gap," relying on rigid timers or reactive moisture thresholds that fail to account for the dynamic Soil-Plant-Atmosphere Continuum (SPAC) or solar power volatility[cite: 5, 48]. [cite_start]This system solves these issues by decoupling biological decision-making from electromechanical execution, ensuring crops receive precise water quantities without wasting scarce energy[cite: 6].

## 🏗️ System Architecture
[cite_start]The control logic is split into two nested loops operating on distinct time scales based on **Time Scale Separation**[cite: 7, 84]:

### 1. The Outer Loop: MPC Supervisor ("The Brain")
* [cite_start]**Frequency:** Runs every 15 minutes ($T_s = 15$ min)[cite: 9].
* [cite_start]**Function:** Estimates crop water demand ($ET_c$) using the **FAO-56 Penman-Monteith** model and calculates the Optimal Flow Setpoint ($Q_{ref}$)[cite: 9].
* [cite_start]**Optimization:** Minimizes a multi-objective cost function that balances crop health against solar energy availability[cite: 9].
* [cite_start]**Rain Logic:** Implements hard constraints to inhibit pumping during precipitation events ($P_{rain} > 0.5 mm/hr$)[cite: 126].

### 2. The Inner Loop: Predictive Adaptive PI ("The Muscle")
* [cite_start]**Frequency:** Runs at 1 kHz[cite: 130].
* [cite_start]**Function:** A robust 2-DOF Predictive Adaptive PI controller that utilizes inverse motor dynamics[cite: 10].
* [cite_start]**Goal:** Rejects voltage disturbances (clouds/voltage sags) with millisecond-level precision to maintain the flow rate targeted by the Supervisor[cite: 10].

## 📊 Performance & Results
[cite_start]Extensive high-fidelity simulations on a modeled $100m^2$ agricultural plot demonstrated significant improvements over industry-standard timer controllers[cite: 11, 153].

| Metric | Standard Timer | Proposed MPC | Improvement |
| :--- | :--- | :--- | :--- |
| **Water Consumed** | 7,200 L | 3,090 L | [cite_start]**57% Savings** [cite: 173] |
| **Energy Consumed** | 450 Wh | 187.5 Wh | [cite_start]**58% Savings** [cite: 173] |
| **Root Zone Error** | 0.052 | 0.008 | [cite_start]**6.5x Precision** [cite: 173] |
| **Rain Response** | 0 min (Wasted) | Instant | [cite_start]**Autonomous** [cite: 173] |

> [cite_start]**Impact:** On a 1-hectare farm, this logic is projected to save over **400,000 Liters per day**[cite: 230].

## 🧠 Mathematical Modeling
[cite_start]The system models three coupled subsystems[cite: 65]:
1.  [cite_start]**Electromechanical:** DC motor dynamics governed by Kirchhoff's Voltage Law and Newton's Second Law[cite: 68].
2.  [cite_start]**Hydraulic:** Pump flow rate assumed proportional to angular velocity[cite: 94].
3.  [cite_start]**Agro-Hydrological:** Soil modeled as a single-layer reservoir (Bucket Model) utilizing the Richards equation[cite: 98].

**Cost Function ($J$):**
The MPC minimizes $J$ to balance moisture tracking and energy usage:
$$min_{Q_{k}}J=w_{1}(\theta_{target}-\theta_{k+1})^{2}+w_{2}\left(\frac{Q_{k}}{G_{solar}(k)+\epsilon}\right)$$
* [cite_start]$w_1$: Penalizes deviation from target moisture (85% Field Capacity)[cite: 121, 122].
* [cite_start]$w_2$: Penalizes pumping when Solar Radiance ($G_{solar}$) is low, shifting load to "free energy" windows[cite: 121, 123].

## 💻 Implementation Details
[cite_start]The logic is designed to be computationally lightweight for embedded systems[cite: 245].

* [cite_start]**Microcontroller:** ESP32 or STM32 (Dual-core architecture allows running Inner/Outer loops on separate cores)[cite: 246].
* [cite_start]**Sensors:** * Capacitive Soil Moisture Probe[cite: 247].
    * [cite_start]DHT22 (Air Temp/Humidity)[cite: 247].
    * [cite_start]Pyranometer (Solar Radiance)[cite: 247].
    * [cite_start]Hall Effect Flow Sensor[cite: 247].
* [cite_start]**Simulation Environment:** MATLAB/Python[cite: 149].

## 🔮 Future Work
* [cite_start]**Adaptive Observers:** To estimate moisture from soil resistivity changes and combat sensor drift/corrosion[cite: 249].
* [cite_start]**Machine Learning:** Integrating ML to infer Crop Coefficients ($K_c$) automatically based on soil drying rates[cite: 251].

## 📚 References
[cite_start]Based on the paper: *Hierarchical Model Predictive Control (MPC) for Energy-Optimal Autonomous Solar Irrigation Systems* by Yashwanth Gowda[cite: 1, 2].

* [1] R. G. Allen et al., "Crop evapotranspiration-Guidelines for computing crop water requirements-FAO Irrigation and drainage paper 56." FAO, 1998.
* [2] N. S. Nise, Control Systems Engineering. 7th ed. John Wiley & Sons, 2014.
