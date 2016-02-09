function [ xs, ys, ts, ps, sizex, sizey ] = loadDVSclean( filename )
%%loadDVSclean Wrapper around supplied scripts to give cleaner data
%   Wrapper for the scripts given by inilabs to ensure data can be used in
%   a uniform way when reading from the 128 or 240. Returns the size in
%   both x and y of the recording plus all data as vectors of doubles.
%   Relies on scripts sensorVersion, extractRetina128EventsFromAddr and
%   getDVSeentsDavis.
%   Inputs:
%       filename
%           Name of the file to load
%
%   Outputs:
%       xs/ys/ts
%           Space-time position of each event
%       ps
%           Polarity of each event
%       sizex
%           Width of vision sensor
%       sizey
%           Height of vision sensor
%

    persistent loaded_file oxs oys ots ops osizex osizey
    
    if strcmp(loaded_file, filename) ...  % if files already loaded
            && exist('oys', 'var') && exist('oxs', 'var') ...
            && exist('ots', 'var') && exist('ops', 'var') ...
            && size(oxs,1) == size(oys,1) &&  size(oys,1) == size(ots, 1) ...
            && size(ots, 1) == size(ops, 1);
        disp('Resetting ( to original) variables... Nothing loaded from file.');
        xs = oxs;
        ys = oys;
        ts = ots;
        ps = ops;
        sizex = osizex;
        sizey = osizey;
        % Assume sizex and sizey are still fine if all else is
    elseif sensorVersion(filename) == 128
        [allAddr, ts] = loadaerdat(filename);
        ts = double(ts);
        [xs, ys, ps] = extractRetina128EventsFromAddr(allAddr);
        ts = unique(ts);  % Remove repeating at the end
        ts = ts(2:end); % Last element will sometimes be noise
        xs = xs(1:size(ts,1));  
        ys = ys(1:size(ts,1));
        ps = ps(1:size(ts,1));
        sizex = 128;
        sizey = 128;
        oxs = xs; oys = ys; ots = ts; ops = ps; osizex = sizex; osizey = sizey;
    else 
        [xs, ys, ps, ts] = getDVSeventsDavis(filename, [0 0 190 180], -1);
        % Invert polarity. Seems like 0 is pos and 1 is neg... (contrasts spec).
        ps(ps == 1) = -1; % Switch to -1 because this is what old format was... 
        ps(ps == 0) = 1;  % should really be 0, but I don't want to refactor
        ts = double(ts);
        ts = unique(ts);  % Remove repeating at the end
        xs = xs(2:size(ts,1));  
        ys = ys(2:size(ts,1));
        ps = ps(2:size(ts,1));
        ts = ts(2:end); % First element will *sometimes* be repeats
        sizex = 190;  % TODO this will be wrong if test pixels are enabled
        sizey = 180; 
        
        
        % CLEAN frequently firing pixels out
        fp = load('freq_pixels.mat');  % Frequently firing pixels (to remove)
        %[bxs, bys] = ind2sub([sizex, sizey], fp.freq_pixels);
        out = zeros(size(xs, 1), 4);
        i = 1;
        for elem = 1:size(xs, 1);
            if find(fp.freq_pixels == sub2ind([sizex, sizey], xs(elem)+1, ys(elem)+1));
                continue;
            end
            out(i, :) = [xs(elem), ys(elem), ts(elem), ps(elem)];
            i = i + 1;
        end
        xs = out(1:i, 1);ys = out(1:i, 2);ts = out(1:i, 3);ps = out(1:i, 4);
        
        oxs = xs; oys = ys; ots = ts; ops = ps; osizex = sizex; osizey = sizey;
    end

    loaded_file = filename;
    
end

