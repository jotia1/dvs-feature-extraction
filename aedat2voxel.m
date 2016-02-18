function [ res, ndata ] = aedat2voxel(indata, xdim, ydim, tdim )
%AEDAT2VOXEL Summary of this function goes here
%   Detailed explanation goes here
%
%   Example usage:
%   [ xs, ys, ts, ps, sizex, sizey ] = loadDVSclean( filename );
%   aedatData = [xs, ys, ts, ps, [sizex; sizey; zeros(size(xs, 1)-2, 1)]];
%   data = aedat2voxel(aedatData, 1, 1, 25);

    persistent firstts lastts ores ondata

    if ischar(indata)l;
        [ xs, ys, ts, ps, sizex, sizey ] = loadDVSclean( filename );
    elseif size(indata, 2) == 5; % assume is [xs, ys, ts, ps, sizes]
        xs = indata(:, 1); ys = indata(:, 2); ts = indata(:, 3);
        ps = indata(:, 4); sizex = indata(1, 5); sizey = indata(2, 5);
    else
        disp('ERROR reading indata');
        return;
    end
    
    if firstts == ts(1) & lastts == ts(end);  % Preloaded data
        disp('Resetting voxel data');
        res = ores;
        ndata = ondata;
        return;
    end

%     xs = xs(sevent:nevents);
%     ys = ys(sevent:nevents);
%     ts = ts(sevent:nevents);
%     ps = ps(sevent:nevents);

    sizet = ts(end) - ts(1); % Won't work for videos over 71 minutes (wrapping)
    tk = tdim*1e3; % Time constant
    numtbuckets = ceil(sizet / tk) + 1;

%     fp = load('freq_pixels.mat');  % Frequently firing pixels (to remove)

    data = zeros(sizex, sizey, numtbuckets, 'int8');
    ep = zeros(sizex, sizey, numtbuckets, 'int8'); % Pos events
    en = zeros(sizex, sizey, numtbuckets, 'int8'); % Neg events
    ndata =  cell(sizex, sizey, numtbuckets); % Count of Pos and Neg, not used

    % Assign 1 to any cell in which a pixel fires
    for i = 1:size(ts,1);
        %disp(i/size(ts,1));
        x = xs(i) + 1;  % Matlab indexs from 1
        y = ys(i) + 1;  % Matlab indexs from 1
        t = ceil((ts(i) - ts(1)) / tk) + 1;
        p = ps(i);

%         % Ignore frequently firing pixels 
%         if find(fp.freq_pixels == sub2ind([sizex, sizey], x, y));
%             continue;
%         end

        % If voxel not yet seen, create struct for it
        if ~isstruct(ndata{x, y, t});
           ndata{x, y, t} = struct('hasPos', 0, 'hasNeg', 0, 'values', []);
        end

        data(x, y, t) = 1;

        if p == -1; % Neg
           en(x, y, t) = 1;
           ndata{x, y, t}.hasNeg = 1;
        else  % Pos
           ep(x, y, t) = 1;
           ndata{x, y, t}.hasPos = 1;
        end

        ndata{x, y, t}.values = [ndata{x, y, t}.values; ts(i), p];

    end

    % Now create Events both and events opposite
    eb = or(en, ep);
    eo = eb;
    
    res = [ep; en; eb; eo];
    firstts = ts(1);
    lastts = ts(end);
    ores = res;
    ondata = ndata;

end

