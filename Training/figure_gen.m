clc; close all; clear all;

% Set the scenario parameters
startTime = datetime(2024, 1, 1, 0, 0, 0);
stopTime = startTime + hours(2);
sampleTime = 20;
sc = satelliteScenario(startTime, stopTime, sampleTime);

% Open Satellite Scenario Viewer
satelliteScenarioViewer(sc);

% Add Satellites
eccentricity = 0;
argumentOfPeriapsis = 0; % degrees
orbitalPeriod = 3600;
Re = earthRadius('m');

% Configuration des paramètres orbitaux pour optimiser la couverture
trueAnomaly = [0; 0; 0];
raan = [0; 74.8; 135.6];
inclination = [37.4, 38, 119];
semiMajorAxis = 550e3 + Re;


sat1 = satellite(sc, semiMajorAxis, eccentricity, inclination(1), raan(1), ...
    argumentOfPeriapsis, trueAnomaly(1), "Name", "Satellite 1", "OrbitPropagator", "two-body-keplerian");

sat2 = satellite(sc, semiMajorAxis, eccentricity, inclination(2), raan(2), ...
    argumentOfPeriapsis, trueAnomaly(2), "Name", "Satellite 2", "OrbitPropagator", "two-body-keplerian");

sat3 = satellite(sc, semiMajorAxis, eccentricity, inclination(3), raan(3), ...
    argumentOfPeriapsis, trueAnomaly(3), "Name", "Satellite 3", "OrbitPropagator", "two-body-keplerian");

% Add Gimbals to Satellites
gimbalSat1Tx = gimbal(sat1, "MountingLocation", [0; 1; 2]); % meters
gimbalSat2Tx = gimbal(sat2, "MountingLocation", [0; 1; 2]); % meters
gimbalSat3Tx = gimbal(sat3, "MountingLocation", [0; 1; 2]); % meters
gimbalSat1Rx = gimbal(sat1, "MountingLocation", [0; -1; 2]); % meters
gimbalSat2Rx = gimbal(sat2, "MountingLocation", [0; -1; 2]); % meters
gimbalSat3Rx = gimbal(sat3, "MountingLocation", [0; -1; 2]); % meters

% Add Receivers and Transmitters to the Gimbals
sat1Rx = receiver(gimbalSat1Rx, "MountingLocation", [0; 0; 1], ...
    "GainToNoiseTemperatureRatio", 3, "RequiredEbNo", 4);
sat2Rx = receiver(gimbalSat2Rx, "MountingLocation", [0; 0; 1], ...
    "GainToNoiseTemperatureRatio", 3, "RequiredEbNo", 4);
sat3Rx = receiver(gimbalSat3Rx, "MountingLocation", [0; 0; 1], ...
    "GainToNoiseTemperatureRatio", 3, "RequiredEbNo", 4);

gaussianAntenna(sat1Rx, "DishDiameter", 0.5);
gaussianAntenna(sat2Rx, "DishDiameter", 0.5);
gaussianAntenna(sat3Rx, "DishDiameter", 0.5);

sat1Tx = transmitter(gimbalSat1Tx, "MountingLocation", [0; 0; 1], ...
    "Frequency", 2.4e9, "Power", 15);
sat2Tx = transmitter(gimbalSat2Tx, "MountingLocation", [0; 0; 1], ...
    "Frequency", 2.4e9, "Power", 15);
sat3Tx = transmitter(gimbalSat3Tx, "MountingLocation", [0; 0; 1], ...
    "Frequency", 2.4e9, "Power", 15);

gaussianAntenna(sat1Tx, "DishDiameter", 0.5);
gaussianAntenna(sat2Tx, "DishDiameter", 0.5);
gaussianAntenna(sat3Tx, "DishDiameter", 0.5);

% Add Ground Stations
gs_main_iot = groundStation(sc, 48.8566, 2.3522, "Name", "Main IoT");
gs_node1 = groundStation(sc, 41.9028, 12.4964, "Name", "Node 1");
gs_node2 = groundStation(sc, 30.0444, 31.2357, "Name", "Node 2");
gs_final = groundStation(sc, 24.7136, 46.6753, "Name", "Ground Station");

% Add Gimbals to Ground Stations
gimbalGsMain = gimbal(gs_main_iot, "MountingAngles", [0; 180; 0], "MountingLocation", [0; 0; -5]);
gimbalGsNode1 = gimbal(gs_node1, "MountingAngles", [0; 180; 0], "MountingLocation", [0; 0; -5]);
gimbalGsNode2 = gimbal(gs_node2, "MountingAngles", [0; 180; 0], "MountingLocation", [0; 0; -5]);
gimbalGsFinal = gimbal(gs_final, "MountingAngles", [0; 0; 0], "MountingLocation", [0; 0; -5]);

% Transmitters and Receivers to Ground Station Gimbals
gs_main_tx = transmitter(gimbalGsMain, "Name", "Main IoT Transmitter", "MountingLocation", [0; 0; 1], "Frequency", 2.4e9, "Power", 30);
gs_node1_tx = transmitter(gimbalGsNode1, "Name", "Node 1 Transmitter", "MountingLocation", [0; 0; 1], "Frequency", 2.4e9, "Power", 30);
gs_node2_tx = transmitter(gimbalGsNode2, "Name", "Node 2 Transmitter", "MountingLocation", [0; 0; 1], "Frequency", 2.4e9, "Power", 30);
gs_final_tx = transmitter(gimbalGsFinal, "Name", "Ground Station Transmitter", "MountingLocation", [0; 0; 1], "Frequency", 2.4e9, "Power", 30);

gaussianAntenna(gs_main_tx, "DishDiameter", 2);
gaussianAntenna(gs_node1_tx, "DishDiameter", 2);
gaussianAntenna(gs_node2_tx, "DishDiameter", 2);
gaussianAntenna(gs_final_tx, "DishDiameter", 2);

gs_main_rx = receiver(gimbalGsMain, "Name", "Main IoT Receiver", "MountingLocation", [0; 0; 1], ...
    "GainToNoiseTemperatureRatio", 3, "RequiredEbNo", 1);
gs_node1_rx = receiver(gimbalGsNode1, "Name", "Node 1 Receiver", "MountingLocation", [0; 0; 1], ...
    "GainToNoiseTemperatureRatio", 3, "RequiredEbNo", 1);
gs_node2_rx = receiver(gimbalGsNode2, "Name", "Node 2 Receiver", "MountingLocation", [0; 0; 1], ...
    "GainToNoiseTemperatureRatio", 3, "RequiredEbNo", 1);
gs_final_rx = receiver(gimbalGsFinal, "Name", "Ground Station Receiver", "MountingLocation", [0; 0; 1], ...
    "GainToNoiseTemperatureRatio", 3, "RequiredEbNo", 1);

gaussianAntenna(gs_main_rx, "DishDiameter", 2);
gaussianAntenna(gs_node1_rx, "DishDiameter", 2);
gaussianAntenna(gs_node2_rx, "DishDiameter", 2);
gaussianAntenna(gs_final_rx, "DishDiameter", 2);

% Point Gimbals
pointAt(gimbalGsMain, sat1);
pointAt(gimbalSat1Rx, gs_main_iot);
pointAt(gimbalSat1Tx, gs_node1);
pointAt(gimbalGsNode1, sat1);
pointAt(gimbalSat2Rx, gs_node1);
pointAt(gimbalSat2Tx, gs_node2);
pointAt(gimbalGsNode2, sat2);
pointAt(gimbalSat3Rx, gs_node2);
pointAt(gimbalSat3Tx, gs_final);
pointAt(gimbalGsFinal, sat3);

% Establish Link
lnk = link(gs_main_tx, sat1Rx, sat1Tx, gs_node1_rx, gs_node1_tx, sat2Rx, sat2Tx, gs_node2_rx, gs_node2_tx, sat3Rx, sat3Tx, gs_final_rx);

% Link Intervals
linkIntervals(lnk);

% Plot Margin
[e, time] = ebno(lnk);
margin = e - gs_final_rx.RequiredEbNo;
figure;
plot(time, margin, "LineWidth", 2);
xlabel("Time");
ylabel("Link Margin (dB)");
grid on;

% Play Scenario
play(sc);

% Adjust Required Eb/No and Plot
gs_final_rx.RequiredEbNo = 10; % decibels
linkIntervals(lnk);

[e_new, time_new] = ebno(lnk);
new_margin = e_new - gs_final_rx.RequiredEbNo;
figure;
plot(time_new, new_margin, "r", time, margin, "b", "LineWidth", 2);
xlabel("Time");
ylabel("Link Margin (dB)");
legend("New Link Margin", "Old Link Margin", "Location", "north");
grid on;
