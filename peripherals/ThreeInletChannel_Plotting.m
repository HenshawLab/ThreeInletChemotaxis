close all

%%

cmc_av = []; beta_t_av = []; beta_T_av = [];
cmc_err = []; beta_t_err = []; beta_T_err = [];
CM = jet(2*NBio);
nb = 1;

for iB = BioReps

    OutDir = [OutputMainDir 'AnalysisOutput/Bio' num2str(iB) '/Analysis/'];
    biostr = ['Bio' num2str(iB)];
    load([OutDir 'Experiment_Analysis.mat']);

    HeatmapDir = [FigDir 'Heatmaps/']; mkdir(HeatmapDir);
    HeatmapPNGDir = [PNGDir 'Heatmaps/']; mkdir(HeatmapPNGDir);

    %% Plot heatmaps for this biological replicate

    fh = figure;
    for iR = 1:NRep
        
        set(fh,'color','white'); box on; hold on;
        imagesc(time,centres,squeeze(pdfmap(:,:,iR)));
        ylabel('Position y \mum','Interpreter','LaTex');
        xlabel('Time t min','Interpreter','LaTex');
        set(gca,'fontsize',10);
        set(gca,'XLim',[min(time),max(time)],'YLim',[min(centres),max(centres)],'YDir','reverse');
        title([ExpName ' Bio ' num2str(iB) ' Rep ' num2str(iR)]);
        colorbar;
        saveas(gcf,[HeatmapDir 'Heatmap_Bio' num2str(iB) '-Replicate' num2str(iR) '.fig']);
        saveas(gcf,[HeatmapPNGDir 'Heatmap_Bio' num2str(iB) '-Replicate' num2str(iR) '.png']);
        clf;

    end
    close(fh);

    fh = figure;
    for iR = 1:NRep
        
        set(fh,'color','white'); box on; hold on;
        imagesc(time,centres,squeeze(pdfmap_nocentre(:,:,iR)));
        ylabel('Position y \mum','Interpreter','LaTex');
        xlabel('Time t min','Interpreter','LaTex');
        set(gca,'fontsize',10);
        set(gca,'XLim',[min(time),max(time)],'YLim',[min(centres),max(centres)],'YDir','reverse');
        title([ExpName ' Bio ' num2str(iB) ' Rep ' num2str(iR)]);
        colorbar;
        saveas(gcf,[HeatmapDir 'Heatmap_Bio' num2str(iB) '-Replicate' num2str(iR) '_nocentre.fig']);
        saveas(gcf,[HeatmapPNGDir 'Heatmap_Bio' num2str(iB) '-Replicate' num2str(iR) '_nocentre.png']);
        clf;

    end
    close(fh);

    %% Plot CMC curve for this replicate with all technical replicates

    fh = figure; set(fh,'color','white'); box on;
    names = cell(1,NRep+1);
    for i = 1:size(Ncmc,1)
        plines(i) = plot(time,Ncmc(i,:),'linewidth',1); hold on;
        names{1,i} = ['Rep. ' num2str(iR)];
    end
    names{1,end} = 'Av.';

    pmean = plot(time,mean(Ncmc,1),'color',CM(2*iB,:),'linewidth',1.5);
    plot([0,max(time)],[0,0],'k--','linewidth',0.75);
    ylim([-1,1]); xlim([0,max(time)]);
    xlabel('Time t min'); ylabel('CMC');
    title([ExpName ' Bio ' num2str(iB)]);

    leg = legend([plines,pmean],names,'location','northeast','box','off');

    % Saving
    saveas(gcf,[FigDir 'CMCCurves_Bio' num2str(iB) '.fig']);
    saveas(gcf,[PNGDir 'CMCCurves_Bio' num2str(iB) '.png']);
    close(fh);

    % Store for collation plot
    cmc_av(nb,:) = mean(Ncmc,1); cmc_err(nb,:) = std(Ncmc,[],1)./sqrt(NRep);
    %% Plot beta curves for this replicate with all technical replicates

    fh = figure; 
    for iplot = 1:2

        if iplot == 1
            beta = Beta_t; ylab = '\beta(t)'; minititle = 'Current time normalization';
            % Store for collation plot
            beta_t_av(nb,:) = mean(beta,1); beta_t_err(nb,:) = std(beta,[],1)./sqrt(NRep);
        else
            beta = Beta_T; ylab = '\beta_T(t)'; minititle = 'End time normalization';
            % Store for collation plot
            beta_T_av(nb,:) = mean(beta,1); beta_T_err(nb,:) = std(beta,[],1)./sqrt(NRep);
        end
        set(fh,'color','white'); box on; hold on;
        names = cell(1,NRep+1);
        
        subplot(1,2,iplot);
        for i = 1:size(beta,1)
            plines(i) = plot(time,beta(i,:),'linewidth',1); hold on;
            names{1,i} = ['Rep. ' num2str(iR)];
        end
        names{1,end} = 'Av.';
        pmean = plot(time,mean(beta,1),'color',CM(2*iB,:),'linewidth',1.5);
        yl = get(gca,'YLim'); plot([0,max(time)],[0,0],'k--','linewidth',0.75);
        xlim([0,max(time)]);

        xlabel('Time t min'); ylabel(ylab,'Interpreter','LaTex');
        title(minititle);

        sgtitle = [ExpName ' Bio ' num2str(iB)];
        leg = legend([plines,pmean],names','location','northeast','box','off');

    end

    % Saving
    saveas(gcf,[FigDir 'BetaCurves_Bio' num2str(iB) '.fig']);
    saveas(gcf,[PNGDir 'BetaCurves_Bio' num2str(iB) '.png']);
    close(fh);

    nb = nb + 1;

end % End of looping over biological replicates

%% Plot all beta replicates on one plot
% Beta(t) (current time normalization)

fh = figure; set(gcf,'color','white'); box on; hold on;
pname = cell(1,NBio);
for i = 1:NBio
    pline(i) = plot(time,beta_t_av(i,:),'color',CM(2*i,:),'linewidth',1);
    ppatch(i) = errpatch(time,beta_t_av(i,:),beta_t_err(i,:),CM(2*i,:),0.3);
    pname{1,i} = ['Bio ' num2str(BioReps(i))];
end
xl = get(gca,'XLim'); plot(xl,[0,0],'k--');

xlabel('Time t min'); ylabel('\beta(t)','Interpreter','Latex');
title([ExpName '\beta(t) Current time normalization']);
leg = legend(pline,pname,'location','northeast','box','off');

saveas(gcf,[FigDir 'AllBeta_t_Plots.fig']);
saveas(gcf,[PNGDir 'AllBeta_t_Plots.png']);
close(fh);

% Beta_T(t) (end time normalization)

fh = figure; set(gcf,'color','white'); box on; hold on;
pname = cell(1,NBio);
for i = 1:NBio
    pline(i) = plot(time,beta_T_av(i,:),'color',CM(2*i,:),'linewidth',1);
    ppatch(i) = errpatch(time,beta_T_av(i,:),beta_T_err(i,:),CM(2*i,:),0.3);
    pname{1,i} = ['Bio ' num2str(BioReps(i))];
end
xl = get(gca,'XLim'); plot(xl,[0,0],'k--');

xlabel('Time t min'); ylabel('\beta(t)','Interpreter','Latex');
title([ExpName '\beta(t) End time normalization']);
leg = legend(pline,pname,'location','northeast','box','off');

saveas(gcf,[FigDir 'AllBeta_T_Plots.fig']);
saveas(gcf,[PNGDir 'AllBeta_T_Plots.png']);
close(fh);

%% Plotting all CMC data on one plot

fh = figure;
set(fh,'color','white'); box on; hold on;

for i = 1:NBio
    pline(i) = plot(time,cmc_av(i,:),'color',CM(2*i,:),'linewidth',1);
    ppatch(i) = errpatch(time,cmc_av(i,:),cmc_err(i,:),CM(2*i,:),0.3);
    pname{1,i} = ['Bio ' num2str(BioReps(i))];
end

xlabel('Time t min'); ylabel('CMC <y>(t)','Interpreter','Latex');
ylim([-1,1]);
title([ExpName '<y>, CMC']);
leg = legend(pline,pname,'location','northeast','box','off');

saveas(gcf,[FigDir 'AllCMC_Plots.fig']);
saveas(gcf,[PNGDir 'AllCMC_Plots.png']);
close(fh);

%%
