%% Update 241206
% Fixed time vector to be correct with the frame rate (1/FPS)

%%
close all
clear pdfmap pdfmap_nocentre

Bins = 0:BinW:ChannelWidth;
for i = 1:length(Bins) - 1
    centres(i) = (Bins(i) + Bins(i+1))/2;
end

for iB = BioReps

    OutDir = [OutputMainDir 'AnalysisOutput/Bio' num2str(iB) '/Analysis/'];
    biostr = ['Bio' num2str(iB)];
    load([OutDir 'parameters_' 'BackgroundImg-' BackgroundImg '.mat'],'params');

    % Setup
    NT = params(1).NumT;
    Nupper= zeros(NRep,NT);
    Nlower = Nupper; BETA = Nupper; CMC = Nupper;
    CellPos = cell(NRep,NT);

    time = [0:NT-1].*(1/FPS)./60; % Time in minutes
    
    for iR = Reps

        ImgDir = [MainDir biostr '/']; WorkingDir = pwd; 
        repname = ['Exp' sprintf('%02d',iR)];

         % Get parameters/images
        BPASS = params(iR).BPASS;
        PKFND = params(iR).PKFND;
        CNT = params(iR).CNT;
        FLIP = params(iR).FLIPUD;
        YL = params(iR).YL;
        if strcmp(BackgroundImg,'mean')
            Bimg = params(iR).img_mean;
        elseif strcmp(BackgroundImg,'median')
            Bimg = params(iR).img_median;
        elseif strcmp(BackgroundImg,'max')
            Bimg = params(iR).img_max;
        elseif strcmp(BackgroundImg,'min')
            Bimg = params(iR).img_min;
        end

        Width = abs(YL(1) - YL(2)).*PixToMum;
        
        % Check for pretracking
        if RUN_PARTICLELOCATION == true

            if iR == Reps(1)
                pdfmap = zeros(length(Bins)-1,NT,NRep);
                pdfmap_nocentre = pdfmap;
            end
    
            % Check for ND2, use image stack if else
            filelist = params(iR).filelist;
            if params(iR).ND2 == true

                bfr = BioformatsImage([ImgDir filelist(iR).name]);
                WB = waitbar(0,'Doing particle location');
                for iframe = 1:NT

                    % Image reading, background subtraction, cropping
                    img0 = mat2gray(getPlane(bfr,1,1,iframe));
                    img = img0 - Bimg;
                    img = img(YL(1):YL(2),:);
                    if params(iR).FLIPUD == 1
                        img = flipud(img);
                    end

                    % Particle location
                    b = bpass(imcomplement(img).*255,BPASS(1),BPASS(2));
                    pk = pkfnd(b,PKFND(1),PKFND(2));
                    cnt = cntrd(b,pk,CNT);
                    Calculations;

                    % Store locations
                    CellPos{iR,iframe} = cnt(:,[1,2]);
                    waitbar(iframe/NT,WB,[repname ' - ' sprintf('Progress: %d %%',floor(iframe*100/NT))]);
                    pause(0.1);
                end
                close(WB);

            else % If image stack
                WB = waitbar(0,'Doing particle location');
                ImgDir = [ImgDir repname '/'];
                for iframe = 1:NT

                    % Image reading, background subtraction, cropping
                    img0 = mat2gray(double(imread([ImgDir filelist(iframe).name])));
                    img = img0 - Bimg;
                    img = img(YL(1):YL(2),:);
                    if params(iR).FLIP == 1
                        img = flipud(img);
                    end

                    % Particle location
                    b = bpass(imcomplement(img).*255,BPASS(1),BPASS(2));
                    pk = pkfnd(b,PKFND(1),PKFND(2));
                    cnt = cntrd(b,pk,CNT);
                    Calculations;

                    % Store locations
                    CellPos{iR,iframe} = cnt(:,[1,2]);
                    waitbar(iframe/NT,WB,[repname ' - ' sprintf('Progress: %d %%',floor(iframe*100/NT))]);
                    pause(0.1);

                end
                close(WB);
                
            end % End of file reading

        end % End of pretracking

    end % End of looping over technical replicates
    
    Nu = Nupper(Reps,:); Nl = Nlower(Reps,:); Ncmc = CMC(Reps,:);
    % Normalizing at each timestep
    Beta_t = (Nu - Nl)./(Nu + Nl);
    % Normalizng at END timespep
    Beta_T = (Nu - Nl)./(Nu(end) + Nl(end));

    % Saving/loading
    if RUN_PARTICLELOCATION == true
        save([OutDir 'Experiment_Analysis.mat'], ...
            'CellPos','Nupper','Nlower','Ncmc', ...
            'Beta_t','Beta_T','time','centres', ...
            'params','pdfmap','pdfmap_nocentre');
    else
        load([OutDir 'ParticleLocations.mat']);
    end
    
end % End of looping over biological replicates
