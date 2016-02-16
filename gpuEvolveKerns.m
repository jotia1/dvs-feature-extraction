%% gpuEvolveKerns
% Evolve kernels competitively using GPU arrays and saving select variables
% at the end. 

%% Wishlist (TODO)
%   - Progress saves (every x evolutions) - Done
%   - Built in option to convert straight to video

%% Settings
nkernels = 2;
nevolutions = 10;
msps = 10;              % Milliseconds per time slice
emptyValue = -1/27;    % Empty space (zeros) in data to be replaced with

filename = 'data/D-7-8-D-nm1-60s.aedat';sevent = 2001; nevents = 4840;
%filename = 'data/animal_farm.aedat'; sevent = 1; nevents = 1600000;

evolutionsPerSave = ceil(max(nevolutions / 5, 1000));
vis_progress = 0;  % Visialise kernel progress while computing
prog_saves = 0;    % Save progress periodically while computing

%% Algorithm - O(Evolution * Kernels^2 * Convolutions)

% Initialise kernels

% for each evolution                                  #Evolutions
    
    % If mod(x) save progress 
    % prev champions convolutions
    % calc champ scores agaisnt eachother

    % for each kernel                                   #Kernels
        % mutate
        % Convolve                                        #Convolutions
        
        % Calculate score of mutant against previous champs (excluding own)
        
        % Fix multiple maxs                                 #kernel
    
        % update champion if mutant better
    
% Save results

%% Code

ffilename = filename;
ffilename(ffilename == '_') = ' ';  % Generate graph friendly name
cjet = colormap;
close gcf; %colormap opens a figure...

[ xs, ys, ts, ps, sizex, sizey ] = loadDVSclean( filename );

xs = xs(sevent:nevents);
ys = ys(sevent:nevents);
ts = ts(sevent:nevents);
ps = ps(sevent:nevents);

aedatData = [xs, ys, ts, ps, [sizex; sizey; zeros(size(xs, 1)-2, 1)]];
loaded = aedat2voxel(aedatData, 1, 1, msps);
data = gpuArray(double(loaded(190*2 + 1: 190*3, :, :)));
clearvars loaded % Clean up a little
zeroz = find(data == 0);
data(zeroz) = emptyValue;

khistory = cell(nevolutions, nkernels); % history of what each kernal was
kvhistory = cell(nevolutions, nkernels); % history of each kernals value
res = gpuArray.zeros([nkernels + 1, size(data)]); % +1 for mutant
oldChampScores = zeros(nkernels, 1);
prevChampTmp = zeros(size(data));
scores = gpuArray.zeros(nkernels + 1, 1);
mutant_wins = [];

if vis_progress;
    prog = figure;
    hold on
end
    
% Initialise kernels
for ikernel = 1 : nkernels
    khistory{1, ikernel} = gpuArray(double(randKern()));
    kvhistory{1, ikernel} = -Inf;
end

% for each evolution
for ievolution = 2 : nevolutions
    disp(ievolution)
    % If mod(x) save progress 
    if prog_saves && mod(ievolution, evolutionsPerSave) == 0;
        % TODO this may cause problems by removing memory from gpu
        outname = sprintf('%d-%d-%dms-%s', nkernels, nevolutions, msps, ...                
            char(datetime('now','Format','d-MM-y-HH:mm:ss'))); 
        data = gather(data);                                                        
        mutant_wins = gather(mutant_wins);                                          
        %sscore = gather(sscore);                                                    
        for k = 1 : numel(khistory)
            khistory{k} = gather(khistory{k});
        end
        for k = 1 : numel(kvhistory)
            kvhistory{k} = gather(kvhistory{k});
        end                                            
        save(outname, 'nevolutions', 'nkernels', 'kvhistory', 'khistory', ...       
            'mutant_wins', 'data');                                       
        disp(outname)  
    end

    % prev champions convolutions
    for convol = 1 : nkernels
        old_champ = khistory{ievolution - 1, convol};
        rr = convn(data, old_champ, 'same');
        rr(zeroz) = 0;  % Only consider 1 centered positions
        res(convol, :, :, :) = rr;
    end
    
    % calc champ scores agaisnt eachother
    cmaxs = squeeze(max(res)); 
    
    % Now deal with ties being attributed to first winner
    dups = zeros(size(cmaxs));
    for iikernel = 1 : nkernels
        dups = dups + (squeeze(res(iikernel, :, :, :)) == cmaxs);
    end
    % champs weighted maxs
    cwmaxs = cmaxs ./ dups; % Share out winnings
    
    % for each kernel
    for ikernel = 1 : nkernels
        champ = khistory{ievolution - 1, ikernel};
        % mutate
        mutant = permuteKern(champ);
        
        % Convolve
        rr = convn(data, mutant, 'same'); 
        rr(zeroz) = 0;
        res(nkernels + 1, :, :, :) = rr;  % TODO unecessary mem copy here
        
        % old champ score
        prevChampTmp = squeeze(res(ikernel, :, :, :)); 
        % TODO FIX this doesnt account for kernel 1 collection
        cwins = find(prevChampTmp == cmaxs);
        champ_score = gather(sum(cwmaxs(cwins)));
        
        % Calculate score of mutant against previous champs (excluding own)
        res(ikernel, :, :, :) = -Inf;  %Set prevChamps spot to -Inf
        
        mmaxs = squeeze(max(res));      %mutants max's
        
        % Now deal with ties being attributed to first winner
        dups = zeros(size(mmaxs));
        for iikernel = 1 : nkernels
            dups = dups + (squeeze(res(iikernel, :, :, :)) == mmaxs);
        end
        dups(find(dups == 0)) = 1;
        mwmaxs = mmaxs ./ dups;
        kwins = find(squeeze(res(nkernels + 1, :, :, :)) == mmaxs);
        
        % Note must use kwins and NOT midxs as midxs defaults wins to k1
        mutant_score = sum(mwmaxs(kwins));
        
        res(ikernel, :, :, :) = prevChampTmp;  % Set champ values back
        
        % update champion if mutant better
        if mutant_score >= champ_score; 
           khistory{ievolution, ikernel} = mutant;
           kvhistory{ievolution, ikernel} = mutant_score;
           mutant_wins = [mutant_wins; ikernel, ievolution];
        else
           khistory{ievolution, ikernel} = champ;
           kvhistory{ievolution, ikernel} = champ_score;         
        end         
        
    end
    
    % Plot kernel values history
    if vis_progress && mod(ievolution, 25) == 0
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

% Save results
outname = sprintf('%d-%d-%dms-%s', nkernels, nevolutions, msps, ...                
    char(datetime('now','Format','d-MM-y-HH:mm:ss'))); 
data = gather(data);                                                        
mutant_wins = gather(mutant_wins);                                          
%sscore = gather(sscore);                                                      
for k = 1 : numel(khistory)
    khistory{k} = gather(khistory{k});
end
for k = 1 : numel(kvhistory)
    kvhistory{k} = gather(kvhistory{k});
end
save(outname, 'nevolutions', 'nkernels', 'kvhistory', 'khistory', ...       
    'mutant_wins', 'data');
