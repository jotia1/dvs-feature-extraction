%% visualiseEvolution
% Visualise the evolution of some kernels
%
% Many variables from the kernel growing stage are required to be loaded in
% the workspace before running ususally done with 'load filename.mat'
function [] = visualiseEvolution(filename, save_vid, outname) 
    
    load(filename);
    
    do_pause = 0;
    if ~exist('save_vid', 'var') 
        save_vid = lower(input('Save? y/[n]: ', 's'));
        do_pause = 1;
    end

    show_winnings = 0;
    if show_winnings;1
        p_fig = figure('Position', [0, 0, 1280, 960]);%, 'visible', 'off');
    end
    
    if strcmp(save_vid, 'y');
        save_vid = 1;
        if ~exist('outname', 'var')
            outname = lower(input('Filename? (add .avi): ', 's'));
        end
        v = VideoWriter(outname);
        v.FrameRate = 1;
        open(v);
    else
        save_vid = 0;
    end
    
    if ~exist('outname', 'var')
        outname = filename;
    end

    zeroz = data == 0;
    subsq = ceil(sqrt(nkernels));
    subr = subsq + 1;

    k_fig = figure('color', 'w', 'Position', [0, 0, 1280, 960]);
    movegui(k_fig,'center');
    if ~do_pause  % just converting videos
        %set(k_fig, 'visible', 'off');
    end
    cjet = [1 1 1; jet];
    res = zeros([nkernels, size(data)]);
    largest = -Inf;

    % Create legend
    leg = cell(nkernels, 1);
    for i = 1:nkernels
       leg{i} = num2str(i); 
    end

    for ikernel = 1 : nkernels
        subplot(subr, subsq, 1:subsq);
        % kernel values plot
        scores = [kvhistory{:, ikernel}];
        colour = cjet(floor(size(cjet, 1) * ikernel / nkernels), :);
%         if ikernel == 1
%             colour = [ 0 0 1];
%         else
%             colour = [1 0 0];
%         end
        hold on
        plot(scores, 'color', colour);
        local_largest =  max(scores(:));
        if local_largest > largest;
           largest = local_largest;
        end

    end
    legend(leg);
    h_line = plot([1; 1], [0; largest], 'k'); % plot verticle moving line
    % plot where mutants win
    %plot(mutant_wins, zeros(1, numel(mutant_wins)), '*');  % TODO - needs updating now mutant_wins format changed

    frame_counter = 1;
    if do_pause 
        pause;
    end
    for ievolution = 1 : 50 : nevolutions
        set(0, 'CurrentFigure', k_fig);
        %subplot(2, 2, [1, 2]);
        subplot(subr, subsq, 1:subsq);
        hold on
        delete(h_line);
        h_line = plot([ievolution; ievolution], [0; largest], 'k');
        title(sprintf('%s - evolution: %d', outname, ievolution));

    %     set(0, 'CurrentFigure', k_fig);
    %     for ikernel = 1 : nkernels
    %         subplot(1, 2, ikernel);
    %         visualiseKern(khistory{ievolution, ikernel}, sprintf('Evo num - %d', ievolution), k_fig);
    %     end

        % Create p_fig diagrams
        %set(0, 'CurrentFigure', p_fig);
        for ikernel = 1 : nkernels

            % Now visualise kernels
            subplot(subr, subsq, subsq + ikernel);
            k = gather(khistory{ievolution, ikernel});
            visualiseKern(k, sprintf('Evo num - %d', ievolution), k_fig);
            colour = cjet(floor(size(cjet, 1) * ikernel / nkernels), :);
            title(sprintf('kernel: %d', ikernel), 'color', colour);

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
            colour = cjet(floor(size(cjet, 1) * ikernel / nkernels), :);
            title(sprintf('Pixels won, evo: %d', ievolution), 'color', colour);
        end

        pause(0.01);

        if save_vid;
            frame = getframe(k_fig);
            writeVideo(v, frame);
        end
        %F(frame_counter) = getframe(k_fig);    
        %frame_counter = frame_counter + 1;

    end


    if save_vid;
        close(v); % finish matlab video
    end
end