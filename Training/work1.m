clc; close all;

startTime = datetime(2024,1,19,8,23,0);
stopTime = startTime + hours(5);
sampleTime = 60;
sc = satelliteScenario(startTime,stopTime,sampleTime);



satelliteScenarioViewer(sc);

% Add satellites 
semiMajorAxis = 10000000;    % meters
eccentricity = 0;
inclination = 0 ; % degrees 
rightAscensionOfAscendingNode= 0; % degree
argumentOfPeriapsis = 0; % degrees 
trueAnomaly = 0;  % degrees 
sat1 = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
    rightAscensionOfAscendingNode, argumentOfPeriapsis, trueAnomaly, "OrbitPropagator","two-body-keplerian"); 

semiMajorAxis = 10000000;                  % meters
eccentricity = 0;
inclination = 30;                          % degrees
rightAscensionOfAscendingNode = 120;       % degrees
argumentOfPeriapsis = 0;                   % degrees
trueAnomaly = 300;                         % degrees
sat2 = satellite(sc, ...
    semiMajorAxis, ...
    eccentricity, ...
    inclination, ...
    rightAscensionOfAscendingNode, ...
    argumentOfPeriapsis, ...
    trueAnomaly, ...
    "Name","Satellite 2", ...
    "OrbitPropagator","two-body-keplerian");


% Add gimbals to satellites
gimbalSat1Tx = gimbal(sat1, ...
    "MountingLocation",[0;1;2]);  % meters
gimbalSat2Tx = gimbal(sat2, ...
    "MountingLocation",[0;1;2]);  % meters
gimbalSat1Rx = gimbal(sat1, ...
    "MountingLocation",[0;-1;2]); % meters
gimbalSat2Rx = gimbal(sat2, ...
    "MountingLocation",[0;-1;2]); % meters

% Receivers and Transmitters to the Gimbals

sat1Rx = receiver(gimbalSat1Rx, ...
    "MountingLocation",[0;0;1], ...      % meters
    "GainToNoiseTemperatureRatio",3, ... % decibels/Kelvin
    "RequiredEbNo",4);                   % decibels
sat2Rx = receiver(gimbalSat2Rx, ...
    "MountingLocation",[0;0;1], ...      % meters
    "GainToNoiseTemperatureRatio",3, ... % decibels/Kelvin
    "RequiredEbNo",4);                   % decibels
gaussianAntenna(sat1Rx, "DishDiameter",0.5);  
gaussianAntenna(sat2Rx, "DishDiameter",0.5);    


sat1Tx = transmitter(gimbalSat1Tx, ...
    "MountingLocation",[0;0;1], ...   % meters
    "Frequency",2.4e9, ...             % hertz
    "Power",15);                      % decibel watts
sat2Tx = transmitter(gimbalSat2Tx, ...
    "MountingLocation",[0;0;1], ...   % meters
    "Frequency",2.4e9, ...             % hertz
    "Power",15);                      % decibel watts

gaussianAntenna(sat1Tx, "DishDiameter",0.5);    % meters
gaussianAntenna(sat2Tx, "DishDiameter",0.5);    % meters

% Add Ground Stations
latitude = 12.9436963;          % degrees
longitude = 77.6906568;         % degrees
gs1 = groundStation(sc, ...
    latitude, ...
    longitude, ...
    "Name","IoT device 1");


latitude = -33.7974039;        % degrees
longitude = 151.1768208;       % degrees
gs2 = groundStation(sc, ...
    latitude, ...
    longitude, ...
    "Name","IoT device 2");

gimbalGs1 = gimbal(gs1, ...
    "MountingAngles",[0;180;0], ... % degrees
    "MountingLocation",[0;0;-5]);   % meters
gimbalGs22 = gimbal(gs2, ...
    "MountingAngles",[0;0;0], ... % degrees
    "MountingLocation",[0;0;-5]);   % meters

gimbalGs2 = gimbal(gs2, ...
    "MountingAngles",[0;180;0], ... % degrees
    "MountingLocation",[0;0;-5]);   % meters

% Transmitters and Receivers to Ground Station Gimbals
gs1Tx = transmitter(gimbalGs1, ...
    "Name","Ground Station 1 Transmitter","MountingLocation",[0;0;1],"Frequency",2.4e9, "Power",30); 
gaussianAntenna(gs1Tx, "DishDiameter",2); 


% First gimbaol config for iot2
gs2Tx = transmitter(gimbalGs2, ...
    "Name","Ground Station 2 Transmitter","MountingLocation",[0;0;1],"Frequency",2.4E9, "Power",30); 
gaussianAntenna(gs2Tx, "DishDiameter",2); 
gs2Rx = receiver(gimbalGs2, ...
    "Name","Ground Station 2 Receiver", ...
    "MountingLocation",[0;0;1], ...        % meters
    "GainToNoiseTemperatureRatio",3, ...   % decibels/Kelvin
    "RequiredEbNo",1);     
gaussianAntenna(gs2Rx, ...
    "DishDiameter",2); % meters

% Second gimbaol config for iot2
gs2Tx2 = transmitter(gimbalGs22, ...
    "Name","Ground Station 2 Transmitter","MountingLocation",[0;0;1],"Frequency",2.4E9, "Power",30); 
gaussianAntenna(gs2Tx2, "DishDiameter",2); 
gs2Rx2 = receiver(gimbalGs22, ...
    "Name","Ground Station 2 Receiver", ...
    "MountingLocation",[0;0;1], ...        % meters
    "GainToNoiseTemperatureRatio",3, ...   % decibels/Kelvin
    "RequiredEbNo",1);     
gaussianAntenna(gs2Rx2, ...
    "DishDiameter",2); % meters

% simulate
pointAt(gimbalGs1,sat1);
pointAt(gimbalSat1Rx,gs1);
pointAt(gimbalSat1Tx,gs2);
pointAt(gimbalGs22,sat1);
pointAt(gimbalGs2,sat2);
pointAt(gimbalSat2Rx,gs2);


% link
lnk = link(gs1Tx,sat1Rx,sat1Tx,gs2Rx2,gs2Tx,sat2Rx);

% link intervals 
linkIntervals(lnk)

play(sc);

% Plot margin
[e, time] = ebno(lnk);
margin = e - gs2Rx.RequiredEbNo;
plot(time,margin,"LineWidth",2);
xlabel("Time");
ylabel("Link Margin (dB)");
grid on;


%  Required Eb/No modification
gs2Rx.RequiredEbNo = 10; % decibels
linkIntervals(lnk)

% plot
[e, newTime] = ebno(lnk);
newMargin = e - gs2Rx.RequiredEbNo;
plot(newTime,newMargin,"r",time,margin,"b","LineWidth",2);
xlabel("Time");
ylabel("Link Margin (dB)");
legend("New link margin","Old link margin","Location","north");
grid on;
%%
sat = satellite(sc,"threeSatelliteConstellation.tle");

show(sat);

groundTrack(sat,"LeadTime",20*60);

ele1 = orbitalElements(sat(1));
ele2 = orbitalElements(sat(2));
ele3 = orbitalElements(sat(3));


%time = datetime(2024,1,19,9,41,0);
%pos = states(sat(1),time,"CoordinateFrame","geographic");
%sprintf("At 9:41AM on January 19th, 2024 the first satellite's"+ ...
%       "latitude is %4.2f degrees .\n"+ ...
%        "Its longitude is %4.2f degrees. It's altitude is %7.2f km.", ...
%        pos(1),pos(2),pos(3)/1000)


gimbalrxSat = gimbal(sat);
gimbaltxSat = gimbal(sat);

gainToNoiseTemperatureRatio = 5;                                                        % dB/K
systemLoss = 3;                                                                         % dB
rxSat = receiver(gimbalrxSat,Name="Satellite Receiver",GainToNoiseTemperatureRatio= ...
    gainToNoiseTemperatureRatio,SystemLoss=systemLoss);

frequency = 2.4e9;                                                                     % Hz
power = 20;                                                                           % dBW
bitRate = 20;                                                                         % Mbps
systemLoss = 3;                                                                       % dB
txSat = transmitter(gimbaltxSat,Name="Satellite Transmitter",Frequency=frequency, ...
    power=power,BitRate=bitRate,SystemLoss=systemLoss);
