%% visualiseEvolution
% Visualise the evolution of some kernels
%
% Many variables from the kernel growing stage are required

k_fig = figure('Position', [0, 0, 640, 480]);
F(nevolutions) = struct('cdata',[],'colormap',[]);

p_fig = figure;
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
h_line = plot([1; 1], [0; largest], 'k');


pause;
for ievolution = 1 : 50 : nevolutions
    set(0, 'CurrentFigure', p_fig);
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
        visualiseKern(khistory{ievolution, ikernel}, sprintf('Evo num - %d', ievolution), p_fig);
        
        % Do conv
        kernel = khistory{ievolution, ikernel};
        rr = convn(data, kernel, 'same');
        rr(zeroz) = 0;  % only zero centered positions
        res(ikernel, :, :, :) = rr;
        
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
    set(0, 'CurrentFigure', k_fig);
    maxs = max(res, [], 4);
    [maxs, imaxs] = max(maxs);
    empty = maxs == 0;
    imaxs(empty) = 0;
    imagesc(squeeze(imaxs));
    colormap(cjet);
    colorbar;
    title(sprintf('Pixels won, evo: %d', ievolution));
    
    pause(0.01);
    F(ievolution) = getframe(k_fig);    
    
end


save_vid = lower(input('Save? y/[n]: ', 's'));
if strcmp(save_vid, 'y');
    % Save anything that has been recorded
    v = VideoWriter('del.avi');
    open(v);
    writeVideo(v, F);
    close(v); % finish matlab video
end