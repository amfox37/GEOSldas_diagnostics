    function [] = write_netcdf_file_2D_grid_v2(fname, ...
        colind, rowind, ll_lons, ll_lats, data, pentad, ...
        start_time, end_time, overwrite, N_out_fields)        

    int_precision   = 'NC_INT';      % precision of fortran tag
    float_precision = 'NC_DOUBLE';    % precision of data in input file
    
    version = 0;

    % check dimensions
    if size(data,1)~=N_out_fields
        error('ERROR: size of data incompatible with N_out_fields')
    end

    % check for presence of optional input "overwrite"
    if ~exist('overwrite','var')
        overwrite = 0;        % default: do NOT overwrite existing files
    end

    % check if file exists
    if exist(fname,'file')
        if overwrite==0
            disp(['RETURNING!!! -- NOT OVERWRITING EXISTING FILE ', fname])
            return
        else
            disp(['OVERWRITING ', fname])
        end
    else
        disp(['writing ', fname])
    end
    
    % Convert the cell arrays to matrices using cell2mat (to deal with all_pentad case)
    year_mat = cell2mat({start_time.year}');
    month_mat = cell2mat({start_time.month}');
    day_mat = cell2mat({start_time.day}');
    hour_mat = cell2mat({start_time.hour}');
    min_mat = cell2mat({start_time.min}');
    sec_mat = cell2mat({start_time.sec}');
    % Use the matrices as input to the datetime function
    d = datetime(year_mat, month_mat, day_mat, hour_mat, min_mat, sec_mat);
    % Convert to serial date number
    serialNum = datenum(d);
    % Subtract serial date number of January 1, 1950
    daysSince1950 = serialNum - datenum('January 1, 1950');
    tmp_start_time = daysSince1950;
   
    % determine number of grid cells ; further check dimensions
    N_grid = size(data,2);

% create netCDF file
netcdf.setDefaultFormat('FORMAT_NETCDF4');
ncid = netcdf.create(fname, 'NETCDF4');

% define dimensions
dimid_grid = netcdf.defDim(ncid, 'grid', N_grid);
dimid_pentad = netcdf.defDim(ncid, 'pentad', N_pentad);
dimid_lon = netcdf.defDim(ncid, 'lon', N_lon);
dimid_lat = netcdf.defDim(ncid, 'lat', N_lat);

% define variables
varid_pentad = netcdf.defVar(ncid, 'pentad', int_precision, [dimid_pentad]);

varid_start_time = netcdf.defVar(ncid, 'start_time', float_precision, [dimid_pentad]);
netcdf.putAtt(ncid, varid_start_time, 'standard_name','start time');
netcdf.putAtt(ncid, varid_start_time, 'long_name','start time');
netcdf.putAtt(ncid, varid_start_time, 'axis','T');
netcdf.putAtt(ncid, varid_start_time, 'units','days since 1950-01-01 00:00:00.0 +0000');

varid_end_time = netcdf.defVar(ncid, 'end_time',float_precision, [dimid_pentad]);
netcdf.putAtt(ncid, varid_end_time, 'standard_name','end time');
netcdf.putAtt(ncid, varid_end_time, 'long_name','end time');
netcdf.putAtt(ncid, varid_end_time, 'axis','T');
netcdf.putAtt(ncid, varid_end_time, 'units','days since 1950-01-01 00:00:00.0 +0000');

varid_N_grid = netcdf.defVar(ncid, 'N_grid', int_precision, []);
varid_colind = netcdf.defVar(ncid, 'colind', float_precision, [dimid_grid]);
varid_rowind = netcdf.defVar(ncid, 'rowind', float_precision, [dimid_grid]);
varid_lon = netcdf.defVar(ncid, 'lon', float_precision, [dimid_lon]);
varid_lat = netcdf.defVar(ncid, 'lat', float_precision, [dimid_lat]);

varid_om = netcdf.defVar(ncid, 'o_mean', float_precision, [dimid_lat dimid_lon dimid_pentad]);
varid_ov = netcdf.defVar(ncid, 'o_std', float_precision, [dimid_lat dimid_lon dimid_pentad]);
varid_mm = netcdf.defVar(ncid, 'm_mean', float_precision, [dimid_lat dimid_lon dimid_pentad]);
varid_mv =  netcdf.defVar(ncid, 'm_std', float_precision, [dimid_lat dimid_lon dimid_pentad]);
varid_mi =  netcdf.defVar(ncid, 'm_min', float_precision, [dimid_lat dimid_lon dimid_pentad]);
varid_ma =  netcdf.defVar(ncid, 'm_max', float_precision, [dimid_lat dimid_lon dimid_pentad]);
varid_ndata =  netcdf.defVar(ncid, 'n_data', float_precision, [dimid_lat dimid_lon dimid_pentad]);


% end define mode
netcdf.endDef(ncid);

% write data
netcdf.putVar(ncid, varid_pentad, pentad);
netcdf.putVar(ncid, varid_start_time, tmp_start_time);
netcdf.putVar(ncid, varid_end_time, tmp_end_time);
netcdf.putVar(ncid, varid_N_grid, N_grid);

netcdf.putVar(ncid, varid_colind, colind);
netcdf.putVar(ncid, varid_rowind, rowind);
netcdf.putVar(ncid, varid_lon, ll_lons);
netcdf.putVar(ncid, varid_lat, ll_lats);

if N_pentad ==1
    
    data_out = ones(N_out_fields,N_lat, N_lon) * -999.0;
    
    for n = 1:N_out_fields
        for i = 1:length(colind)
            data_out(n,rowind(i),colind(i)) = data(n,i);
        end
    end
    
    netcdf.putVar(ncid,varid_om,data_out(1, :, :));
    netcdf.putVar(ncid,varid_ov,data_out(2, :, :));
    netcdf.putVar(ncid,varid_mm,data_out(3, :, :));
    netcdf.putVar(ncid,varid_mv,data_out(4, :, :));
    netcdf.putVar(ncid,varid_mi,data_out(6, :, :));
    netcdf.putVar(ncid,varid_ma,data_out(7, :, :));
    netcdf.putVar(ncid,varid_ndata,data_out(5, :, :));
else
    
    data_out = ones(N_out_fields, N_lat,N_lon,N_pentad) * -999.0;
    
    for n = 1:N_out_fields
        for i = 1:length(colind)
            data_out(n,rowind(i),colind(i),:) = data(n,i,:);
        end
    end
    
    netcdf.putVar(ncid,varid_om,data_out(1, :, :,:));
    netcdf.putVar(ncid,varid_ov,data_out(2, :, :,:));
    netcdf.putVar(ncid,varid_mm,data_out(3, :, :,:));
    netcdf.putVar(ncid,varid_mv,data_out(4, :, :,:));
    netcdf.putVar(ncid,varid_mi,data_out(6, :, :,:));
    netcdf.putVar(ncid,varid_ma,data_out(7, :, :,:));
    netcdf.putVar(ncid,varid_ndata,data_out(5, :, :,:));
end

% close netCDF file
netcdf.close(ncid);

    end



