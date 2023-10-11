clear

% addpath('../../shared/matlab/');
addpath('/discover/nobackup/amfox/current_GEOSldas/GEOSldas/src/Applications/LDAS_App/util/shared/matlab')

% load the data
load('write_netcdf_2D_inputs.mat')

fname_out = 'test_2D_write.nc';

%test the write function
write_netcdf_file_2D_grid(fname_out, i_out, j_out, lon_out, lat_out, inc_angle, data2D, int_Asc, pentad, start_time, end_time, overwrite, Nf, write_ind_latlon, 'scaling', obsnum)

fname_out = 'test_2D_write_v2.nc';

%test the write function
write_netcdf_file_2D_grid_v2(fname_out, i_out, j_out, lon_out, lat_out, data2D, pentad, start_time, end_time, overwrite, Nf)