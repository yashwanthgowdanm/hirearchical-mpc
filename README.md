# Hierarchical Model Predictive Control (MPC) for Energy-Optimal Autonomous Solar Irrigation Systems

## 🚀 Overview
This project presents a novel **Hierarchical Cyber-Physical Control Architecture** designed to optimize solar-powered irrigation systems in off-grid regions. 

Standard solar irrigation solutions often suffer from a "Smartness Gap," relying on rigid timers or reactive moisture thresholds that fail to account for the dynamic Soil-Plant-Atmosphere Continuum (SPAC) or solar power volatility. This system solves these issues by decoupling biological decision-making from electromechanical execution, ensuring crops receive precise water quantities without wasting scarce energy.

## 🏗️ System Architecture
The control logic is split into two nested loops operating on distinct time scales based on **Time Scale Separation**:

### 1. The Outer Loop: MPC Supervisor ("The Brain")
* **Frequency:** Runs every 15 minutes ($T_s = 15$ min).
* **Function:** Estimates crop water demand ($ET_c$) using the **FAO-56 Penman-Monteith** model and calculates the Optimal Flow Setpoint ($Q_{ref}$).
* **Optimization:** Minimizes a multi-objective cost function that balances crop health against solar energy availability.
* **Rain Logic:** Implements hard constraints to inhibit pumping during precipitation events ($P_{rain} > 0.5 mm/hr$).

### 2. The Inner Loop: Predictive Adaptive PI ("The Muscle")
* **Frequency:** Runs at 1 kHz.
* **Function:** A robust 2-DOF Predictive Adaptive PI controller that utilizes inverse motor dynamics.
* **Goal:** Rejects voltage disturbances (clouds/voltage sags) with millisecond-level precision to maintain the flow rate targeted by the Supervisor.

## 📊 Performance & Results
Extensive high-fidelity simulations on a modeled $100m^2$ agricultural plot demonstrated significant improvements over industry-standard timer controllers.

| Metric | Standard Timer | Proposed MPC | Improvement |
| :--- | :--- | :--- | :--- |
| **Water Consumed** | 7,200 L | 3,090 L | **57% Savings** |
| **Energy Consumed** | 450 Wh | 187.5 Wh | **58% Savings** |
| **Root Zone Error** | 0.052 | 0.008 | **6.5x Precision** |
| **Rain Response** | 0 min (Wasted) | Instant | **Autonomous** |

> **Impact:** On a 1-hectare farm, this logic is projected to save over **400,000 Liters per day**.

## 🧠 Mathematical Modeling
The system models three coupled subsystems:
1.  **Electromechanical:** DC motor dynamics governed by Kirchhoff's Voltage Law and Newton's Second Law.
2.  **Hydraulic:** Pump flow rate assumed proportional to angular velocity.
3.  **Agro-Hydrological:** Soil modeled as a single-layer reservoir (Bucket Model) utilizing the Richards equation.

**Cost Function ($J$):**
The MPC minimizes $J$ to balance moisture tracking and energy usage:
$$min_{Q_{k}}J=w_{1}(\theta_{target}-\theta_{k+1})^{2}+w_{2}\left(\frac{Q_{k}}{G_{solar}(k)+\epsilon}\right)$$
* $w_1$: Penalizes deviation from target moisture (85% Field Capacity).
* $w_2$: Penalizes pumping when Solar Radiance ($G_{solar}$) is low, shifting load to "free energy" windows.

## 💻 Implementation Details
The logic is designed to be computationally lightweight for embedded systems.

* **Microcontroller:** ESP32 or STM32 (Dual-core architecture allows running Inner/Outer loops on separate cores).
* **Sensors:** * Capacitive Soil Moisture Probe.
    * DHT22 (Air Temp/Humidity).
    * Pyranometer (Solar Radiance).
    * Hall Effect Flow Sensor.
* **Simulation Environment:** MATLAB/Python.

## 🔮 Future Work
* **Adaptive Observers:** To estimate moisture from soil resistivity changes and combat sensor drift/corrosion.
* **Machine Learning:** Integrating ML to infer Crop Coefficients ($K_c$) automatically based on soil drying rates.

## 📚 References
* [1] R. G. Allen et al., "Crop evapotranspiration-Guidelines for computing crop water requirements-FAO Irrigation and drainage paper 56." FAO, 1998.
* [2] N. S. Nise, Control Systems Engineering. 7th ed. John Wiley & Sons, 2014.
