%% 
%   This script will apply convolutions to an aedat file specified by 
%   filename to extract visial features and visualise them.

%% Initialisation
filename = 'data/D-7-8-D-nm1-60s.aedat'; nevents = 7100;
%filename = 'data/ball.aedat'; nevents = 100000;
%filename = 'animal_farm.aedat'; nevents = 50000;
sevent = 1;

[ xs, ys, ts, ps, sizex, sizey ] = loadDVSclean( filename );

ffilename = filename;
ffilename(ffilename == '_') = ' ';  % Generate graph friendly name

xs = xs(sevent:nevents);
ys = ys(sevent:nevents);
ts = ts(sevent:nevents);
ps = ps(sevent:nevents);

sizet = ts(end) - ts(1); % Won't work for videos over 71 minutes (wrapping)
tk = 25e3; % Time constant
numtbuckets = ceil(sizet / tk) + 1;

plot_intensity = 0;

% % ranges of each set of data
ebslice = 1:sizex;
eoslice = sizex+1:2*sizex;
epslice = 2*sizex+1:3*sizex;
enslice = 3*sizex+1:4*sizex;

aedatData = [xs, ys, ts, ps, [sizex; sizey; zeros(size(xs, 1)-2, 1)]];
data = aedat2voxel(aedatData, 1, 1, 25);
eb = data(190*2 + 1: 190*3, :, :);
zeroz = find(eb == 0);


%% Convolutions
disp('Starting Convolutions');

[ convs, knames, ksum ] = loadKernals('kernels/discrim1800');
nkernels = size(convs, 1);
convspe = size(convs, 1) + 1; % number of convs plus empty category...
% res dimensions(convolutions, x, y, timeslice);
res = zeros([convspe, sizex, sizey, numtbuckets]); %*4 for all inputs

% Serial implementation
for i=1:size(convs, 1);
    disp(i/size(convs, 1));
    kern = convs{i, :, :, :};
    res(i, :, :, :) = convn(eb, kern./6, 'same');% / ksum{i}; %conv and normalise
end

%%  Colour max


% Visualise results
h1 = figure;
operatorFig = figure;
caxis([0 7]);
colorbar;
if plot_intensity
    intensityFig = figure;
end
caxis([-1 1]);
colorbar;
%splot = figure;
cjet = [jet; 1 1 1];

%colours = rand(size(convs, 1), 3);
colours = [1 1 1;
            0 0 1;
            0.5 0.5 0.5;
            0 1 0;
            0 0 0;
            1 0 0];

F(numtbuckets) = struct('cdata',[],'colormap',[]);

for v = 1: nkernels
    tmp = res(v, :, :, :);
    tmp(zeroz) = 0;
    res(v, :, :, :) = tmp;
end

disp('Press enter to start.');
pause;
for i=1:numtbuckets;
    %% Plot Indiv feature activations
    set(0, 'CurrentFigure', h1)
    subplot(1, 2, 1);
    operator = 1;
    im = squeeze(res(operator, ebslice, :, i));
    %im(zeroz) = 0;
    imshow(rot90(mat2gray(im, [-1, 1])));
    %imshow(rot90(mat2gray(squeeze(res(operator, ebslice, :, i)), [-1, 1])));
    %title(knames{operator});
    xlabel('x');
    ylabel('y');
    
    subplot(1, 2, 2);
    operator = 2;
    im = squeeze(res(operator, ebslice, :, i));
    %im(zeroz) = 0;
    imshow(rot90(mat2gray(im, [-1, 1])));
    title(knames{operator});
    xlabel('x');
    ylabel('y');
    
    %% Plot the winning kernel
    set(0, 'CurrentFigure', operatorFig);
    im = squeeze(res(:, ebslice, :, i));
    %im(zeroz) = 0;
    [maxs imaxs] = max(im);
    empty = maxs == 0;
    imaxs(empty) = convspe;
    imagesc(rot90(squeeze(imaxs)));
    colormap(cjet);
    colorbar;
    caxis([1 3]);
    title(sprintf('kernel ID %d of %d', i, numtbuckets));
    F(i) = getframe(operatorFig);

    
    %% Plot each kernels intensity
    if plot_intensity
        set(0, 'CurrentFigure', intensityFig);
        imagesc(rot90(squeeze(maxs)));
        colormap(jet);
        colorbar;
        caxis([-1 1]);
        title(sprintf('Intensity image %d of %d', i, numtbuckets));
    end
    
    %[maxs imaxs] = max(res(:, ebslice, :, i));
    %points = cell(size(convs, 1), 1);
    
    i
    pause(0.001);   
end


save_vid = lower(input('Save? y/[n]: ', 's'));
if strcmp(save_vid, 'y');
    % Save anything that has been recorded
    v = VideoWriter('del.avi');
    open(v);
    writeVideo(v, F);
    close(v); % finish matlab video
end
















