% Convert to pixels, find largest width of image
y = cnt(:,2).*PixToMum;
ymax = size(img,1).*PixToMum;

% Find particles at the top and bottom
ytop = y(y<=BW);
ybottom = y(y>=(ymax - BW));

Nupper(iR,iframe) = numel(ytop);
Nlower(iR,iframe) = numel(ybottom);

% CMC calculation
CMC(iR,iframe) = (mean(y)- (ymax/2))./(ymax/2);

% Heatmap PDFs
h = histogram(y,'BinEdges',Bins,'normalization','pdf');
pdfmap(:,iframe,iR) = h.Values';

% Heatmap PDFs no centre
y_nocentre = [y(y <= (ChannelWidth - Exclusion));y(y >= (ChannelWidth + Exclusion))];
h = histogram(y_nocentre,'BinEdges',Bins,'normalization','pdf');
pdfmap_nocentre(:,iframe,iR) = h.Values';