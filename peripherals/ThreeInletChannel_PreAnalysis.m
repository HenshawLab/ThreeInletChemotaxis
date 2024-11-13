%% Make background image

if RUN_BACKGROUND == true
    
    for iB = BioReps
        
        OutDir = [OutputMainDir 'AnalysisOutput/Bio' num2str(iB) '/Analysis/'];
        mkdir(OutDir);        

        for iR = Reps

            ImgDir = [MainDir biostr '/']; WorkingDir = pwd; cd(ImgDir);
            repname = ['Exp' sprintf('%02d',iR)];
            
            % Get filelist and number of timepoints
            if strcmp(imgextension,'*.nd2')                
                filelist = dir('*.nd2'); cd(WorkingDir);
                bfr = BioformatsImage([ImgDir filelist(iR).name]);
                NT = bfr.sizeT;
                ND2 = true;
                img0 = getPlane(bfr,1,1,1);
            else
                ImgDir = [ImgDir repname '/'];
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
                    img_stack(:,:,it) = mat2gray(imread([ImgDir filelist(it).name]));
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
        load([OutDir 'parameters.mat'],'params');

        for iR = Reps

            ImgDir = [MainDir biostr '/']; WorkingDir = pwd; cd(ImgDir);
            repname = ['Exp' sprintf('%02d',iR)];

            % Read mid time-point image
            if params(iR).ND2 == true
            else
            end
            

        end % End of looping over technical replicates
    end % End of looping over biological replicates

end

%%

%             %% Mean background image
%             if ND2 == true
%                 bfr = BioformatsImage([ImgDir filelist(iR).name]);
%                 img0 = getPlane(bfr,1,1,1); Bimg = zeros(size(img0,1),size(img0,2));
% 
%                 for iT = 1:NT
%                     img = mat2gray(double(getPlane(bfr,1,1,iT)));
%                     Bimg = Bimg + img;
%                 end % End of looping over time
% 
%             else 
% 
%                 img0 = imread([ImgDir filelist(1).name]);
%                 Bimg = zeros(size(img0,1),size(img0,2));
% 
%                 for iT = 1:NT
%                     img = mat2gray(double(imread([ImgDir filelist(i).name])));
%                     Bimg = Bimg + img;
%                 end
% 
%             end % End of nd2 processing
% 
%             Bimg = Bimg./NT;
%             
%             %%
% 
%             save([Output_Background ExpName '_' biostr '_' repstr '_MeanBackground.mat'],'Bimg');