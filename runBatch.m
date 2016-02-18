% for each voxel size
vsizes = [15, 9, 5, 3, 1];
for voxelSpatial = vsizes
    %filename = 'data/D-7-8-D-nm1-60s.aedat'; sevent = 1; nevents = 48400;
    %filename = 'data/M2a01.aedat'; sevent = 1; nevents = 55000;
    filename = 'data/S6d.aedat'; sevent = 1; nevents = 47200;
    %filename = 'data/animal_farm.aedat'; sevent = 1; nevents = 1600000;
    
    timescales = [100, 25, 10, 1];
    nksizes = [2, 4, 8, 16, 32];
    % for each timescale
    for msps = timescales;
        % for each number of kernels
        for nkernels = nksizes;
            disp('----- Starting Evolution -----');
            fprintf('%s-%d-%d-%dms-SWO-%s\n', filename(6:end-6), voxelSpatial, nkernels, msps, ...                
                char(datetime('now','Format','d-MM-y-HH-mm-ss'))); 
            tic
            gpuEvolveKerns;
            toc
        end
    end
    clear; % Remove all old variables (worried about mem)
    vsizes = [15, 9, 5, 3, 1];
end
