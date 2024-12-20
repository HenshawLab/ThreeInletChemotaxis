close all
clear all 
clc

matlabrc; 
addpath('peripherals');

%% Updates:
% 241129 - added in variable "RUN_BACKGROUND_MEANONLY" to setup to
% calculate just the mean background image. Dramatically reduces hardware
% resource requirements, limits choice of background image to the mean.
% Other labelling fixes of plots

% 241206 - added in extra plot of particle positions, included
% "optionsaving.m" which saves an addition structure for accessing
% information in plotting

%% Instructions:
% Keep in the subfolder "peripherals", as the subcodes are kept there
% Does not need to be with the main data directory, I have just included an
% example of it

% Folder Layout:
% Main Directory
    % Bio Replicates 
        % Technical Replicates

% Experiment layout
% Top of image - Stimulus
% Middle of image - Cells
% Bottom of image - ASW

% Set the variable "chem_location" to top or bottom at the start to account
% for this

%% Setup - change these values

% Inputs
MainDir = 'D:/WheretheDataIs/'; % Important to end with the "/"
OutputMainDir = 'D:/PutMyOutputsHere/'; % Where you would like to save the analysis
ExpName = 'Experiment name and info'; % Name you want on the plot titles/folder name
WorkingDir = pwd; % Working Directory, where we are currently
imgextension = '*.nd2'; % Image format (.tiff, .tif, .jpg etc.)

BioReps = [1]; % Bio replicates. For example, if you did 4 replicates but only want the first, second, and fourth, set this to be [1,2,4]
Reps = [1,2,3]; % Technical replicates, same style as BioReps
NBio = length(BioReps); NRep = length(Reps);

% Choices for preprocessing/analysis - so you don't have to run the whole thing for a
% specific section. Default: true
% Main files
RUN_PREANALYSIS = false;
RUN_ANALYSIS = false;
RUN_PLOTTING = true;

% Sub sections (overidden by above checks)
RUN_BACKGROUND = true;
RUN_BACKGROUND_MEANONLY = false; % Only compute mean background - recommended for reduced computational load
RUN_CROPPING = true;
RUN_PRETRACKPARAMETERS = true;

RUN_PARTICLELOCATION = true;

% Set the particle to be 'bright' or 'dark' dependent on your imaging setup
% Default: dark
particle_type = 'dark';

% Type of background image for analysis. Default: mean
BackgroundImg = 'mean'; % Options: mean, median

% Width of accumulation region (from boundaries, in microns)
accum_width = 200;

BinW = 25; % Bin width (microns) for heatmap
Exclusion = 75; % Width (+/-) that is excluded from centre of heatmaps for PLOTTING PURPOSES ONLY
ChannelWidth = 1000; % Channel width in microns (for plotting ONLY)

Mag = 10; % TOTAL Magnification
PixSize = 6.5; % Pixel size of your camera CHECK
PixToMum = PixSize/Mag; % Conversion of pixels to microns
FPS = 1; % Frame rate (frames per second)

BPASS = [1,30]; % Starting values for bpass.m
PKFND = [4,7]; % Starting values for pkfnd.m
CNT = 7; % Starting value for cntrd.m

%% Outputs - don't change these

FigDir = [OutputMainDir 'Figures/'];
PNGDir = [FigDir 'PNGS/']; 
mkdir(FigDir); mkdir(PNGDir);

optionsaving;

%% Run codes

if RUN_PREANALYSIS == true
    ThreeInletChannel_PreAnalysis;
end
if RUN_ANALYSIS == true
    ThreeInletChannel_Analysis;
end
if RUN_PLOTTING == true
    ThreeInletChannel_Plotting;
end
