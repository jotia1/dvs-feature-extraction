%% visualiseEvolution
% Visualise the evolution of some kernels
%
% Many variables from the kernel growing stage are required to be loaded in
% the workspace before running ususally done with 'load filename.mat'

show_winnings = 0;
if show_winnings;
    p_fig = figure('Position', [0, 0, 640, 480]);
end
F(1) = struct('cdata',[],'colormap',[]);
zeroz = data == 0;

k_fig = figure;
cjet = [1 1 1; jet];
res = zeros([nkernels, size(data)]);
largest = -Inf;

for ikernel = 1 : nkernels
    subplot(2, 2, [1,2]);
    % kernel values plot
    scores = [kvhistory{:, ikernel}];
    %colour = cjet(floor(size(cjet, 1) * ikernel / nkernels), :);
    if ikernel == 1
        colour = [ 0 0 1];
    else
        colour = [1 0 0];
    end
    hold on
    plot(scores, 'color', colour);
    local_largest =  max(scores(:));
    if local_largest > largest;
       largest = local_largest;
    end
end
h_line = plot([1; 1], [0; largest], 'k'); % plot verticle moving line
% plot where mutants win
plot(mutant_wins, zeros(1, numel(mutant_wins)), '*');


frame_counter = 1;
pause;
for ievolution = 1 : 10 : nevolutions
    set(0, 'CurrentFigure', k_fig);
    subplot(2, 2, [1, 2]);
    hold on
    delete(h_line);
    h_line = plot([ievolution; ievolution], [0; largest], 'k');
    
%     set(0, 'CurrentFigure', k_fig);
%     for ikernel = 1 : nkernels
%         subplot(1, 2, ikernel);
%         visualiseKern(khistory{ievolution, ikernel}, sprintf('Evo num - %d', ievolution), k_fig);
%     end
    
    % Create p_fig diagrams
    %set(0, 'CurrentFigure', p_fig);
    for ikernel = 1 : nkernels
        
        % Now visualise kernels
        subplot(2, 2, ikernel+2);
        k = gather(khistory{ievolution, ikernel});
        visualiseKern(k, sprintf('Evo num - %d', ievolution), k_fig);
        
        % Do conv
        if show_winnings
            kernel = gather(khistory{ievolution, ikernel});
            rr = convn(data, kernel, 'same');
            rr(zeroz) = 0;  % only zero centered positions
            res(ikernel, :, :, :) = rr;
        end
        
        %draw
%         subplot(2, 2, ikernel);
%         [maxs imaxs] = max(squeeze(res(ikernel, :, :, :)), [], 3);
%         empty = maxs == 0;
%         imaxs(empty) = 0;
%         imagesc(rot90(squeeze(imaxs)));
%         colormap(cjet);
%         colorbar;
%         %caxis([1 3]);
%         title(sprintf('Pixels won, evo: %d', ievolution));        
    end
    
    if show_winnings
        set(0, 'CurrentFigure', p_fig);
        maxs = max(res, [], 4);
        [maxs, imaxs] = max(maxs);
        empty = maxs == 0;
        imaxs(empty) = 0;
        imagesc(squeeze(imaxs));
        colormap(cjet);
        colorbar;
        title(sprintf('Pixels won, evo: %d', ievolution));
    end
    
    pause(0.01);
    
    F(frame_counter) = getframe(k_fig);    
    frame_counter = frame_counter + 1;
    
end


save_vid = lower(input('Save? y/[n]: ', 's'));
if strcmp(save_vid, 'y');
    % Save anything that has been recorded
    outname = lower(input('Filename (add .avi)? y/[n]: ', 's'));
    v = VideoWriter(outname);
    open(v);
    writeVideo(v, F);
    close(v); % finish matlab video
end