function [ ] = plotDVS3d( filename, start, finish, polstr, unit )
%PLOTDVS3D Plot DVS data from start events until end
%   Plot a dvs data file from start events until end events with ploarity
%   equal to pol (being 'pos', 'neg', 'both')

    mult = 1;
    if strcmp(unit, 's') == 1  % User wants seconds
        % convert to us then logical index
        mult = 1e6;
    elseif strcmp(unit, 'ms') == 1  % User specified ms
        mult = 1e3;
    elseif strcmp(unit, 'e') == 1
        mult = 1;
    else % If here invalid
        disp('Invalid unit specified, options are: s, ms, e');
        return;
    end

    [infomatrix1, infomatrix2, allTs, infomatrix3, sx, sy] = ...
        loadDVSclean(filename);
    allTs = int32(allTs);
    starttimeus = allTs(1);
    endtimeus = allTs(end);

    if strcmp(unit, 'e') == 1
        i = start;
        j = finish;
    else
        i = find(allTs > mult*start + starttimeus, 1);
        j = find(allTs > mult*finish + starttimeus, 1);
    end
    xs = infomatrix1(i:j);
    ys = infomatrix2(i:j);
    ts = allTs(i:j);
    ps = infomatrix3(i:j);
    
    green = [20, 181, 58]./256;
    figure;
    if strcmp(polstr, 'pos') == 1 
        xs = xs(ps==1,:);
        ys = ys(ps==1,:);
        ts = ts(ps==1,:);
        plot3(xs, ys, ts,'*', 'MarkerSize',2, 'Color', green );
    elseif strcmp(polstr, 'neg') == 1
        xs = xs(ps==-1,:);
        ys = ys(ps==-1,:);
        ts = ts(ps==-1,:);
        plot3(xs, ys, ts,'r*', 'MarkerSize',2)
    elseif strcmp(polstr, 'both') == 1
        xsn = xs(ps==-1,:);
        ysn = ys(ps==-1,:);
        tsn = ts(ps==-1,:);
        xsp = xs(ps==1,:);
        ysp = ys(ps==1,:);
        tsp = ts(ps==1,:);
        plot3(xsn, ysn, tsn, 'r*', 'MarkerSize',2);
        hold on;
        plot3(xsp, ysp, tsp,'*', 'MarkerSize',2, 'Color', green );
    else
        disp('Polarity setting not recognised, must be pos, neg or both.');
        return;
    end

    title(strcat('plot of: ', filename)) 
    xlabel('x', 'fontsize',14,'fontweight','bold','color',[1 0 0])
    ylabel('y','fontsize',14,'fontweight','bold','color',[0 0 0]) 
    zlabel('Time','fontsize',14,'fontweight','bold','color',[0 0 1]) 
end

