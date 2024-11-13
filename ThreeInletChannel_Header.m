close all
clear all 
clc

matlabrc; 
addpath('peripherals');

%% Instructions:
% Keep in the subfolder "peripherals", as the subcodes are kept there
% Does not need to be with the main data directory, I have just included an
% example of it

% Folder Layout:
% Main Directory
    % Bio Replicates 
        % Technical Replicates

% Experiment layout
% Top of image - ASW
% Middle of image - Cells
% Bottom of image - Stimulant

% Set the variable "chem_location" to top or bottom at the start to account
% for this

%% Setup - change these values

% Inputs
MainDir = 'D:/Alginate/240823/MB_10/'; % Important to end with the "/"
OutputMainDir = 'D:/Alginate/Results/241016_DigestedAlginate_2e_2e-2/'; % Where you would like to save the analysis
ExpName = 'ExperimentName'; % Name you want on the plot titles/folder name
WorkingDir = pwd; % Working Directory, where we are currently
imgextension = '*.nd2'; % Image format (.tiff, .tif, .jpg etc.)

BioReps = [1,2,3]; % Bio replicates. For example, if you did 4 replicates but only want the first, second, and fourth, set this to be [1,2,4]
Reps = [1,2,3]; % Technical replicates, same style as BioReps
NBio = length(BioReps); NRep = length(Reps);

concentrations = [200,49,3.6,0.12,0.0012,0];

% chem_location = 'bottom'; % Choices: 'bottom' , 'top'. Location of chemotstimulant relative to the channel

% Choices for preprocessing/analysis - so you don't have to run the whole thing for a
% specific section. Default: true
RUN_BACKGROUND = false;
RUN_CROPPING = false;
RUN_PRETRACKPARAMETERS = false;

RUN_PARTICLELOCATION = true;
RUN_ANALYSIS = true;

% Set the particle to be 'bright' or 'dark' dependent on your imaging setup
% Default: dark
particle_type = 'dark';

% Image naming parameters
filenaming = 'default'; % 'custom' for images as provided, 'default' if enough leading zeros to put files in correct order

% Width of accumulation region (from boundaries, in microns)
accum_width = 200;

BinW = 25; % Bin width (microns) for heatmap
Exclusion = 75; % Width (+/-) that is excluded from centre of heatmaps for PLOTTING PURPOSES ONLY

Mag = 4; % TOTAL Magnification
PixSize = 6.5; % Pixel size of your camera CHECK
PixToMum = PixSize/Mag; % Conversion of pixels to microns

BPASS = [1,7]; % Starting values for bpass.m
PKFND = [5,7]; % Starting values for pkfnd.m
CNT = 7; % Starting value for cntrd.m

%% Outputs - don't change these

% OutputMainDir = 'ThreeInlet_Analysis/'; mkdir(OutputMainDir);
% Output_Background = [OutputMain 'BackgroundImages/']; 
% Output_Cropping = [OutputMain 'CroppingLimits/'];
% Output_Pretrack = [OutputMain 'PretrackingParameters/'];
% mkdir(Output_Background); mkdir(Output_Cropping); mkdir(Output_Pretrack);
% OutputDir = [OutputMainDir ExpName '/']; mkdir(OutputDir);
% PreProcDir = [OutputMainDir 'PreProcessing/']; % Place where preproc will be saved
% mkdir(PreProcDir);
% ExperimentOutDir = [OutputMainDir '/' ExpName '/'];
% mkdir(ExperimentOutDir);

% Output directories
% mkdir([ExperimentOutDir 'Bacteria_Positions/']);
% mkdir([ExperimentOutDir 'AccumulationCurves/']);
% mkdir([ExperimentOutDir 'Preprocessing/']);

FigDir = [ExperimentOutDir 'Figures/'];
PNGDir = [FigDir 'PNGS/']; 
mkdir(FigDir); mkdir(PNGDir);
mkdir([FigDir 'Heatmaps/']); mkdir([PNGDir 'Heatmaps']);
mkdir([FigDir 'Heatmaps/CentreOmitted/']); mkdir([PNGDir 'Heatmaps/CentreOmitted/']);
BetaFigDir = [OutputMainDir 'Beta/Figs/'];
BetaDir = [OutputMainDir 'Beta/'];
BetaPNGDir = [OutputMainDir 'Beta/Figs/PNGS/'];

mkdir(BetaDir); mkdir(BetaFigDir); mkdir(BetaPNGDir);

%% Run codes

ThreeInlet_PreAnalysis;
% Wake_MCD_Analysis;
% Wake_MCD_BetaPlotting;
% Wake_MCD_MakeSpreadsheets;