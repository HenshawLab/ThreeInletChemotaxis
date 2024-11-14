%% Make background image

if RUN_BACKGROUND == true
    
    for iB = BioReps
        
        OutDir = [OutputMainDir 'AnalysisOutput/Bio' num2str(iB) '/Analysis/'];
        mkdir(OutDir); biostr = ['Bio' num2str(iB)];    

        for iR = Reps

            ImgDir = [MainDir biostr '/']; WorkingDir = pwd; 
            repname = ['Exp' sprintf('%02d',iR)];
            
            % Get filelist and number of timepoints (NT)
            if strcmp(imgextension,'*.nd2') 
                cd(ImgDir);
                filelist = dir('*.nd2'); cd(WorkingDir);
                bfr = BioformatsImage([ImgDir filelist(iR).name]);
                NT = bfr.sizeT;
                ND2 = true;
                img0 = getPlane(bfr,1,1,1);
            else
                ImgDir = [ImgDir repname '/']; cd(ImgDir);
                filelist = dir(imgextension); cd(WorkingDir);
                NT = size(filelist,1);
                ND2 = false;
                img0 = imread([ImgDir filelist(1).name]);
            end

            % Preallocate memory
            img_stack = zeros(size(img0,1),size(img0,2),NT);

            % Stack images
            if ND2 == true
                for it = 1:NT
                    img = getPlane(bfr,1,1,it);
                    img_stack(:,:,it) = mat2gray(img);
                end
            else
                for it = 1:NT
                    img_stack(:,:,it) = mat2gray(double(imread([ImgDir filelist(it).name])));
                end
            end

            % Averaging
            params(iR).img_median = median(img_stack,3);
            params(iR).img_mean = mean(img_stack,3);
            params(iR).img_max = max(img_stack,[],3);
            params(iR).img_min = min(img_stack,[],3);
            params(iR).repname = repname;
            params(iR).NumT = NT;
            params(iR).ND2 = ND2;
            params(iR).filelist = filelist;
            
            % Preallocation for next steps
            params(iR).XL = [NaN,NaN];
            params(iR).YL = [NaN,NaN];
            params(iR).BPASS = [NaN,NaN];
            params(iR).PKFND = [NaN,NaN];
            params(iR).CNT = NaN;

        end % End of looping over technical replicates
        
        save([OutDir 'parameters.mat'],'params');
        
    end % End of looping over biological replicates

end % End of run background

%% Cropping

if RUN_CROPPING == true

    figure;
    set(gcf,'Position',get(0,'Screensize')); hold on;
    disp('Dont close the figure please!')

    for iB = BioReps

        % Where the analysis for this bio replicate should be saved to
        OutDir = [OutputMainDir 'AnalysisOutput/Bio' num2str(iB) '/Analysis/'];
        load([OutDir 'parameters.mat'],'params'); biostr = ['Bio' num2str(iB)];  

        for iR = Reps

            ImgDir = [MainDir biostr '/'];
            repname = ['Exp' sprintf('%02d',iR)];
            filelist = params(iR).filelist;

            % Read mid time-point image
            if params(iR).ND2 == true
                bfr = BioformatsImage([ImgDir filelist(iR).name]);
                img = mat2gray(getPlane(bfr,1,1,floor(bfr.sizeT/2))); 
            else
                ImgDir = [ImgDir repname '/']; cd(ImgDir);
                filelist = dir(imgextension); cd(WorkingDir);
                img = mat2gray(double(imread([ImgDir filelist(floor(NT/2)).name])));
            end

            % Show image to crop
            clf;
            imshow(img,[]);
            % UI text
            disp(['Replicate: ' repname]);
            disp('Two clicks: first at top boundary, second at lower boundary');
            % Get clicks
            [xi,yi] = ginput(2);
            params(iR).XL = round(xi'); params(iR).YL = round(yi');

        end % End of looping over technical replicates

        save([OutDir 'parameters.mat'],'params');

    end % End of looping over biological replicates

end

%% Particle identification and image flipping

if RUN_PRETRACKPARAMETERS == true

    close all
    figure;
    set(gcf,'Position',get(0,'Screensize')); hold on;

    for iB = BioReps
        
        % Where the analysis for this bio replicate should be saved to
        OutDir = [OutputMainDir 'AnalysisOutput/Bio' num2str(iB) '/Analysis/'];
        load([OutDir 'parameters.mat'],'params'); biostr = ['Bio' num2str(iB)];  

        for iR = Reps
            
            ImgDir = [MainDir biostr '/'];
            repname = ['Exp' sprintf('%02d',iR)];
            filelist = params(iR).filelist;

            % Ask if images need to be flipped so that the stimulus is at
            % the top
            disp('Does this replicate need to be flipped to put the stimulus on top? 0 = No, 1 = Yes :' )
            F = input('Flip up/down? 1 = Yes ');
            if F~= 1
                F = 0;
            else
                F = 1;
            end 
            params(iR).FLIPUP = F;
            clc;
            
            % Read mid time-point image
            if params(iR).ND2 == true
                bfr = BioformatsImage([ImgDir filelist(iR).name]);
                img = mat2gray(getPlane(bfr,1,1,floor(bfr.sizeT/2))); 
            else
                ImgDir = [ImgDir repname '/']; cd(ImgDir);
                filelist = dir(imgextension); cd(WorkingDir);
                img = mat2gray(double(imread([ImgDir filelist(floor(NT/2)).name])));
            end
            
            if ~exist('BackgroundImg')
                BackgroundImg = 'mean';
            end
            % Select background image
            if strcmp(BackgroundImg,'mean')
                bimg = params(iR).img_mean;
            elseif strcmp(BackgroundImg,'median')
                bimg = params(iR).img_median;
            elseif strcmp(BackgroundImg,'max')
                bimg = params(iR).img_max;
            elseif strcmp(BackgroundImg,'min')
                bimg = params(iR).img_min;
            end
            yl = params(iR).YL;
            clf;

            sgtitle(repname,'Interpreter','None');
            img = img - bimg;

            HAPPY = false;
            imshow(img,[]); hold on;
            
            % Invert if particle type is dark
            if ~exist('particle_type')
                particle_type = 'dark';
            end
            if strcmp(particle_type,'dark')
                img = imcomplement(img);
            end

            while HAPPY ~= true
                
                b = bpass(img.*255,BPASS(1),BPASS(2));
                pk = pkfnd(b,PKFND(1),PKFND(2));
                cnt = cntrd(b,pk,CNT);

                pts = plot(cnt(:,1),cnt(:,2),'rx','linewidth',1);
                HAPPY = input('Happy with particle location?  0 = No, 1 = Yes :');

                if HAPPY ~= 1
                    disp(['Existing value for BPASS: ' num2str(BPASS(1)) ' ' num2str(BPASS(2))]);
                    BPASS = input('New value for BPASS: [bp1,bp2] ');
                    disp(['Existing value for PKFND: ' num2str(PKFND(1)) ' ' num2str(PKFND(2))]);
                    PKFND = input('New value for: PKFND: [pk1 pk2] ');
                    disp(['Existing value for CNT:' num2str(CNT)]);
                    CNT = input('New value for: CNT: [CNT] ');
                    delete(pts); clc;
                else 
                    HAPPY = 1; break
                end

            end % End of pretracking parameters loop

            params(iR).BPASS = BPASS;
            params(iR).PKFND = PKFND;
            params(iR).CNT = CNT;

        end % End of looping over technical replicates

        save([OutDir 'parameters_' 'BackgroundImg-' BackgroundImg '.mat'],'params');

    end % End of looping over biological replicates

end