%% KernComGrow
% Grow a community of intially random kerns simultaneously
sevent = 1;

filename = 'data/D-7-8-D-nm1-60s.aedat';sevent = 1; nevents = 7100;
%filename = 'data/animal_farm.aedat'; nevents = 1600000;

ffilename = filename;
ffilename(ffilename == '_') = ' ';  % Generate graph friendly name

[ xs, ys, ts, ps, sizex, sizey ] = loadDVSclean( filename );

xs = xs(sevent:nevents);
ys = ys(sevent:nevents);
ts = ts(sevent:nevents);
ps = ps(sevent:nevents);

aedatData = [xs, ys, ts, ps, [sizex; sizey; zeros(size(xs, 1)-2, 1)]];
data = aedat2voxel(aedatData, 1, 1, 25);
data = data(190*2 + 1: 190*3, :, :);
zeroz = find(data == 0);
data(zeroz) = 0;

nkernels = 2;
nevolutions = 6000;
outname = 'nm1-2k-6000e-zero-2'
khistory = cell(nevolutions, nkernels); % history of what each kernal looked like
kvhistory = cell(nevolutions, nkernels); % history of each kernals value

% Create kernels with initial value 0
for i = 1:nkernels;
    khistory{1, i} = randKern();
    kvhistory{1, i} = -Inf;
end


cjet = colormap;

if isGPUCluster()
    disp('yes on cluster');
    data = gpuArray(double(data));  % Copy data to GPU  
end

mscores = zeros(nevolutions, nkernels, 'gpuArray') * -Inf;
cscores = zeros(nevolutions, nkernels, 'gpuArray') * -Inf;
sscore = zeros(nevolutions, nkernels, 'gpuArray') * -Inf;
mutant_wins = [];
prog = figure;
hold on
% For each evolution
for ievolution = 2 : nevolutions   
    %% Show a graph of the last evolution
    res = zeros(nkernels + 1, 190, 180, size(data, 3), 'gpuArray'); % +1 for mutant
    % Performance of champions
    for convol = 1 : nkernels
        old_champ = double(khistory{ievolution - 1, convol});
        rr = convn(data, old_champ, 'same');
        rr(zeroz) = 0;  % Only consider 1 centered positions
        res(convol, :, :, :) = rr;
    end
    
    %% Do next evolution
    fprintf('Evolution number: %d\n', ievolution);
      
    for ikernel = 1 : nkernels;
        
        % mutate
        champ = khistory{ievolution - 1, ikernel};
        mutant = permuteKern(champ);
        
        % Perform convolutions with mutant
        rr = convn(data, mutant, 'same'); 
        rr(zeroz) = 0;
        res(nkernels + 1, :, :, :) = rr;
        
        
        [maxs imaxs] = max([res(1:ikernel-1, :, :, :); zeros(1, 190, 180, size(data, 3)) ; res(ikernel+1:end, :, :, :)]);  % Calculate the mutants score
        %[maxs imaxs] = max(res(:, :, :, :));
        
        empty = maxs == 0;  % Deal with empty space being attributed to kernel 1
        imaxs(empty) = 0;
        
        mwins = imaxs == nkernels + 1;
        mutant_score = sum(maxs(mwins));
        
        % Calculate the champions score
        [cmaxs cimaxs] = max(res(1:nkernels, :, :, :));
        cempty = cmaxs == 0;  % Deal with empty space being attributed to kernel 1
        cimaxs(cempty) = 0;
        
        cwins = cimaxs == ikernel;
        champ_score = sum(cmaxs(cwins));
        
        sscore(ievolution, ikernel) = nnz(res(1:nkernels, :, :, :) == 0)/numel(res);
        
        % if improved, make it current
        if mutant_score >= champ_score; 
           khistory{ievolution, ikernel} = mutant;
           kvhistory{ievolution, ikernel} = mutant_score;
           mutant_wins = [mutant_wins; ievolution];
        else
           khistory{ievolution, ikernel} = champ;
           kvhistory{ievolution, ikernel} = champ_score;         
        end 
        
        mscores(ievolution, ikernel) = mutant_score;
        cscores(ievolution, ikernel) = champ_score;
        
    end
    
    % Plot kernel values history
    if mod(ievolution, 100) == 0
        set(0, 'CurrentFigure', prog)
        for ikernel = 1 : nkernels
            scores = [kvhistory{:, ikernel}];
            %colour = cjet(floor(size(cjet, 1) * ikernel / nkernels), :);
            if ikernel == 1
                colour = [ 0 0 1];
            else
                colour = [1 0 0];
            end
                
            plot(scores, 'color', colour);
            %plot(scores, '.', 'color', rand(3, 1));!
        end
        title(sprintf('Kernel values over time, %s from %d to %d', ffilename, sevent, nevents));
        xlabel('Evolution number');
        ylabel('Sum of values of voxels won');

        % Create legend
        leg = cell(nkernels, 1);
        for i = 1:nkernels
           leg{i} = num2str(i); 
        end
        legend(leg);
        
        pause(0.001);
    end
end

figure;
hold on;
% Plot kernel values history
for ikernel = 1 : nkernels
    scores = [kvhistory{:, ikernel}];
    colour = cjet(floor(size(cjet, 1)*ikernel / nkernels), :);
    plot(scores, 'color', colour);
end
title(sprintf('Kernel values over time, %s from %d to %d', ffilename, sevent, nevents));
xlabel('Evolution number');
ylabel('Number pixels won by each kernel');

% Create legend
leg = cell(nkernels, 1);
for i = 1:nkernels
   leg{i} = num2str(i); 
end
legend(leg);
hold off


figure;
hold on
for i = 1 : nkernels
    colour = cjet(floor(size(cjet, 1) * i / nkernels), :);
    plot(mscores(:, i), 'color', colour);
    plot(cscores(:, i), '--', 'color', colour);
end
title(sprintf('Mutant and champ scores over evolution, %s from %d to %d', ffilename, sevent, nevents));



figure;
hold on
% Plot kernel values history
for ikernel = 1 : nkernels
    plot(sscore(:, ikernel), 'color', rand(3, 1));
end
title(sprintf('Percent number of zeros in result, %s from %d to %d', ...
    ffilename, sevent, nevents));
xlabel('Evolution number');
ylabel('Percentage of zeros');

% Will need to save variables to visualise later
if isGPUCluster()
    % Generate filename: nKernels-nevolutions-date 
    if ~exist('outname', 'var')
        outname = sprintf('%d-%d-%s', nkernels, nevolutions, ...
            char(datetime('now','Format','d-MM-y-HH:mm:ss')));
    end
    % Collect everything from GPU
    data = gather(data);
    mutant_wins = gather(mutant_wins);
    sscore = gather(sscore);
    khistory = gather(khistory);
    kvhistory = gather(kvhistory);
    save(outname, 'nevolutions', 'nkernels', 'kvhistory', 'khistory', ...
        'sscore', 'mutant_wins', 'data');
    disp(outname)
end
