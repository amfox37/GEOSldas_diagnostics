clear

% addpath('../../shared/matlab/');
addpath('/discover/nobackup/amfox/current_GEOSldas/GEOSldas/src/Applications/LDAS_App/util/shared/matlab')

% load the data
load('write_netcdf_2D_inputs.mat')

fname_out = 'test_2D_write.nc';

%test the write function
% write_netcdf_file_2D_grid(fname_out, i_out, j_out, lon_out, lat_out, inc_angle, data2D, int_Asc, pentad, start_time, end_time, overwrite, Nf, write_ind_latlon, 'scaling', obsnum)

fname_out = 'test_2D_write_single_p_compressed.nc';

resol = 0.25;
    
% Define 1/4 degree lat/lon grid
% Define lower-left corner coordinates and grid cell size
ll_lon = -180;
ll_lat = -90;

d_lon = resol;
d_lat = resol;

% Calculate number of longitude and latitude grid cells
n_lon = round(360/ d_lon);
n_lat = round(180 / d_lat);

% Calculate longitude and latitude values for the grid
ll_lons = linspace(ll_lon, ll_lon + (n_lon-1)*d_lon, n_lon);
ll_lats = linspace(ll_lat, ll_lat + (n_lat-1)*d_lat, n_lat);

%test the write function
write_netcdf_file_2D_grid_v2(fname_out, i_out, j_out, ll_lons, ll_lats, data2D, pentad, start_time, end_time, overwrite, Nf, ll_lon, ll_lat, d_lon, d_lat)

clear

load('test_data_out_M36_ASCAT_04012015_03312021.mat');

% fname_out = 'test_2D_write_v3.nc';
%         write_netcdf_file_2D_grid(fname_out, i_out, j_out, lon_out, lat_out, ...
%                   inc_angle, data_o, int_Asc, [1:73], ...  
%                   start_time_p, end_time_p, overwrite, ...
%                   Nf, write_ind_latlon, 'scaling',...
%                   obsnum)
              
pentad = [1:73];              
fname_out = 'test_2D_write_all_p_compressed.nc';
write_netcdf_file_2D_grid_v2(fname_out, i_out, j_out, ll_lons, ll_lats, data_o, pentad, start_time_p, end_time_p, overwrite, Nf, ll_lon, ll_lat, d_lon, d_lat)


