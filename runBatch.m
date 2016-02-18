% for each voxel size
vsizes = [15, 9, 5, 3, 1];
for voxelSpatial = vsizes
    filename = 'data/D-7-8-D-nm1-60s.aedat';sevent = 2001; nevents = 4840;

    timescales = [100, 25, 10, 1];
    nksizes = [2, 4, 8, 16, 32];
    % for each timescale
    for msps = timescales;
        % for each number of kernels
        for nkernels = nksizes;
            disp('----- Starting Evolution -----');
            fprintf('%s-%d-%d-%dms-SWO-%s\n', ffilename, voxelSpatial, nkernels, msps, ...                
                char(datetime('now','Format','d-MM-y-HH:mm:ss'))); 
            gpuEvolveKerns;
        end
    end
    clear; % Remove all old variables (worried about mem)
    vsizes = [15, 9, 5, 3, 1];
end