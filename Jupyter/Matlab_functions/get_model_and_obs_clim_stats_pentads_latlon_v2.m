
function [] = get_model_and_obs_clim_stats_pentads_latlon_v2( species_names,              ...
    run_months, exp_path, exp_run, domain, start_year, end_year,   ...
    dt_assim, t0_assim, species, combine_species_stats, obs_param, ...
    hscale, w_days, Ndata_min, prefix )

%
% get_model_and_obs_clim_stats.m
%
% Compute mean, stdv of model and observations from tile-based 
% "innov" files for a selection of species.
%
% The main purpose of this function is to aggregate the information 
% from the "innov" files so that the climatology statistics can 
% be used in scaling of the observations before assimilation.
%
% One file with statistics is generated for every DOY (1,...,365).
% The temporal smoothing/averaging window (w_days) is given in days.
%
% We calcualte the bias correction factors and write on a regular 0.25 degree 
% lat/lon grid as there is no regular grid for ASCAT observations

%
% GDL, aug 2013: added 'convert_grid' (= EASEv2_M36, EASE_M36, ...)
%                to project the Obs (always M36 for SMOS) and Fcst to M36 
%                M09 obs are administered by tiles (0) that could be anywhere
%                around the center of the observed pixel (M36)
%                -----------
%                | X X X X |
%                | X O O X |
%                | X O O X |
%                | X X X X |
%                -----------
% GDL, jan 2014: the above issue that "any" M09 tile in the center (0)
%                could potentially administer the M36 obs is not true
%                anymore with later LDASsa-tags. 
%                => no need to pass on 'convert_grid' for tags later than
%                the summer of 2013
% reichle, qliu, 13 July 2022:
%                "convert_grid" is still needed to limit the number of tiles
%                in the scaling parameter file.  With "convert_grid" turned on, 
%                only the M09 tile to the northeast of the M36 center point 
%                is kept in the scaling parameter file, consistent with the 
%                "tmp_shift_lat" and "tmp_shift_lon" operations in the SMOS
%                and SMAP Fortran readers.  (It is not clear if this matlab 
%                function works properly if there is no M09 [land] tile 
%                immediately to the northeast of the M36 center point.  In 
%                such a case, the Fortran reader assigns the nearest M09
%                land tile as the tile that administers the obs.)
%                Presumably, scaling parameters for all M09 tiles could be kept
%                if they are stored in (compressed) nc4 format.  In this case,
%                the NaN values for the scaling parameters of 15 out of each 16
%                M09 tiles can be compressed to almost nothing.
%
% -------------------------------------------------------------------
% begin user-defined inputs
% -------------------------------------------------------------------

nodata = -9999;
nodata_tol = 1e-4;
overwrite = 1;
Nf = 7;
N_pentads = 73;
write_ind_latlon = 'latlon_id';
print_each_DOY = 0;
print_each_pentad = 1;
print_all_pentads = 1;

resol = 0.25;

int_Asc = 3;
inc_angle = -9999;

disp('ASSUMING ACAT observations/undefined observation grid');
disp(['Calculating scaling parameters on grid with resolution = ', num2str(resol) , ' degrees']);

if combine_species_stats
    N_species = 1;
else
    N_species = length(species);
end

inpath  = [ exp_path, '/', exp_run, '/output/', domain ];

outpath = [ inpath, '/stats/z_score_clim_db' ];

% create outpath if it doesn't exist
if ~exist(outpath, 'dir')
    mkdir(outpath);
end

% assemble output file name
ind  = start_year == min(start_year);
mi_m = min(run_months(ind));
ind  = end_year == max(end_year);
ma_m = max(run_months(ind));

D(1) = 1;
P(1) = 1;
if mi_m > 1
    D(1) = sum(days_in_month(2014, 1:mi_m-1)) + 1;
    P(1) = ceil(D(1) / 5);
end
D(2) = sum(days_in_month(2014, 1:ma_m));
P(2) = floor(D(2) / 5);

if run_months(1) ~= run_months(end) && run_months(2) ~= run_months(end)
    disp('WARNING: incomplete pentad-windows; loop through additional months to get complete pentads');
end

fname_out_base_d = [outpath,  '/', prefix, ...
    num2str(min(start_year)), '_doy', num2str(D(1)), '_', ...
    num2str(max(end_year)), '_doy', num2str(D(2)), ...
    '_W_', num2str(w_days), 'd_Nmin_', num2str(Ndata_min)];

fname_out_base_p = [outpath, '/', prefix, ...
    num2str(min(start_year)), '_p', num2str(P(1)), '_', ...
    num2str(max(end_year)), '_p', num2str(P(2)), ...
    '_W_', num2str(round(w_days/5)), 'p_Nmin_', num2str(Ndata_min)];

%======================================================

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

% Create grid index
obsnum         = (1:n_lon*n_lat)';
[i_out, j_out] = ind2sub([n_lon, n_lat], obsnum);
lon_out        = ll_lons(i_out)';
lat_out        = ll_lats(j_out)';
N_gridcells    = length(obsnum);
  
% initialize output statistics
o_data_sum  = NaN(N_species, N_gridcells, w_days);
m_data_sum  = NaN(N_species, N_gridcells, w_days);
o_data_sum2 = NaN(N_species, N_gridcells, w_days);
m_data_sum2 = NaN(N_species, N_gridcells, w_days);
m_data_min  = NaN(N_species, N_gridcells, w_days);
m_data_max  = NaN(N_species, N_gridcells, w_days);
N_data      = NaN(N_species, N_gridcells, w_days);

data_out = NaN(N_species, Nf, N_gridcells, N_pentads);
data2D   = NaN(Nf, N_gridcells);

% -------------------------------------------------------------		  

% make sure t0_assim is *first* analysis time in a day

t0_assim = mod( t0_assim, dt_assim );

count = 0;

for imonth = 1:length(run_months)

    month = run_months(imonth);

    for day = 1:days_in_month( 2014, month) %2014 = random non-leap year
     
        if count < w_days
            count = count + 1;
        else
            count = w_days;
        end

        for seconds_in_day = t0_assim:dt_assim:(86400-1)

            hour = floor(seconds_in_day/3600);
            minute = floor((seconds_in_day-hour*3600)/60);
            seconds = seconds_in_day-hour*3600-minute*60;

            if (seconds ~= 0)
                input('something is wrong! Ctrl-c now')
            end

            for year = start_year(imonth):end_year(imonth)

                YYYYMMDD = [num2str(year, '%4.4d'), num2str(month, '%2.2d'), num2str(day, '%2.2d')];
                HHMM = [num2str(hour, '%2.2d'), num2str(minute, '%2.2d')];

                % read innov files
                fname = [inpath, '/ana/ens_avg/', 'Y', YYYYMMDD(1:4), '/', 'M', YYYYMMDD(5:6), '/', exp_run, '.ens_avg.ldas_ObsFcstAna.', YYYYMMDD, '_', HHMM, 'z.bin'];
                ifp = fopen(fname, 'r', 'l');

                if (ifp > 0) % Proceed only if file exists
                    fclose(ifp);
                    [date_time, obs_assim, obs_species, obs_tilenum, obs_lon, obs_lat, obs_obs, obs_obsvar, obs_fcst, obs_fcstvar, obs_ana, obs_anavar] = read_ObsFcstAna(fname);

                    % remove tiles when there is no obs_fcst (obs_fcst == 0 in innov output when missing)
                    idx = find(obs_fcst == 0);
                    obs_assim(idx) = [];
                    obs_species(idx) = [];
                    obs_tilenum(idx) = [];
                    obs_lon(idx) = [];
                    obs_lat(idx) = [];
                    obs_obs(idx) = [];
                    obs_obsvar(idx) = [];
                    obs_fcst(idx) = [];
                    obs_fcstvar(idx) = [];
                    obs_ana(idx) = [];
                    obs_anavar(idx) = [];

                    % extract species of interest
                    ind = [];
                    for scnt = 1:N_species

                        if combine_species_stats
                            ind = find(ismember(obs_species, species));
                            this_species = species(scnt);
                        else
                            ind = find(obs_species == this_species);
                        end

                        if ~isempty(ind)
                            obs_tilenum_i = obs_tilenum(ind);
                            obs_obs_i = obs_obs(ind);
                            obs_fcst_i = obs_fcst(ind);
                            obs_lon_i = obs_lon(ind);
                            obs_lat_i = obs_lat(ind);

                            % Check if any location receives more than 1 obs (or 1 species)
                            tmp = sort(obs_tilenum_i);
                            same_tile = find(diff(tmp) == 0, 1);
                            if ~isempty(same_tile) && ~combine_species_stats
                                error('multiple obs of the same species at one location? - only last one in line is used');
                            end

                            % Put obs lat/lon on our grid and figure out obsnum/grid index
                            i_idx = floor((obs_lon_i - ll_lon) / d_lon) + 1;
                            j_idx = floor((obs_lat_i - ll_lat) / d_lat) + 1;
                            [~, obs_idx] = ismember([i_idx, j_idx], [i_out, j_out], 'rows');
                            obs_i = obsnum(obs_idx);

                            o_data_sum(scnt, obs_i, count) = nansum([o_data_sum(scnt, obs_i, count); obs_obs_i']);
                            m_data_sum(scnt, obs_i, count) = nansum([m_data_sum(scnt, obs_i, count); obs_fcst_i']);
                            o_data_sum2(scnt, obs_i, count) = nansum([o_data_sum2(scnt, obs_i, count); obs_obs_i'.^2]);
                            m_data_sum2(scnt, obs_i, count) = nansum([m_data_sum2(scnt, obs_i, count); obs_fcst_i'.^2]);
                            m_data_min(scnt, obs_i, count) = nanmin([m_data_min(scnt, obs_i, count); obs_fcst_i']);
                            m_data_max(scnt, obs_i, count) = nanmax([m_data_max(scnt, obs_i, count); obs_fcst_i']);
                            N_data(scnt, obs_i, count) = nansum([N_data(scnt, obs_i, count); ~isnan(obs_obs_i)']);
                        end
                    end
                end
            end
        end

        if count >= w_days %wait initially until enough data is built up
            end_time.year  = 2014;
            end_time.month = month;
            end_time.day   = day;  
            end_time.hour  = hour;  
            end_time.min   = minute;
            end_time.sec   = seconds;

            start_time     = augment_date_time( -floor(w_days*(24*60*60)), end_time );

            % At the end of each day, collect the obs and fcst of the last
            % w_day period, and write out a statistics-file at [w_day - floor(w_day/2)]

            o_data_sum(abs(o_data_sum - nodata) <= nodata_tol) = NaN;
            m_data_sum(abs(m_data_sum - nodata) <= nodata_tol) = NaN;

            % data_out = zeros(N_out_fields,1:N_tiles,N_angle);
        
            for i = 1:N_species
                N_hscale_window = nansum(N_data(i,:,1:w_days),3);
                if w_days == 95
                    N_hscale_inner_window = nansum(N_data(i,:,41:55),3);
                end
                data2D(1,:) = nansum(o_data_sum(i,:,1:w_days),3);
                data2D(1,:) = data2D(1,:)./N_hscale_window;
                data2D(2,:) = sqrt(nansum(o_data_sum2(i,:,1:w_days),3)./N_hscale_window - data2D(1,:).^2);
                data2D(3,:) = nansum(m_data_sum(i,:,1:w_days),3)./N_hscale_window;
                data2D(4,:) = sqrt(nansum(m_data_sum2(i,:,1:w_days),3)./N_hscale_window - data2D(3,:).^2);
                data2D(5,:) = N_hscale_window;
                data2D(6,:) = nanmin(m_data_min(i,:,1:w_days),[],3);  % Want to use minimum mean daily value
                data2D(7,:) = nanmax(m_data_max(i,:,1:w_days),[],3);  % Want to use maximum mean daily value

                data2D([1:Nf],N_hscale_window<Ndata_min) = NaN;

                data_out(isnan(data_out)) = nodata; % not sure why this here

                DOY = augment_date_time(-floor(w_days*(24*60*60)/2.0), end_time).dofyr;
                if(is_leap_year(end_time.year) && DOY>=59)
                    DOY = DOY-1;
                    error('This code should never hit a leap year');
                end

                if print_each_DOY
                    if combine_species_stats
                        fname_out = [fname_out_base_d, '_spALL_DOY', num2str(DOY,'%3.3d'), '.nc4'];
                    else
                        fname_out = [fname_out_base_d,'_sp', char(species_names(i)),'_DOY', num2str(DOY,'%3.3d'), '.nc4'];
                    end
                    if (exist(fname_out)==2 && overwrite)
                        disp(['output file exists. overwriting', fname_out])
                    elseif (exist(fname_out)==2 && ~overwrite) 
                        disp(['output file exists. not overwriting. returning'])
                        disp(['writing ', fname_out])
                        return
                    else
                        disp(['creating ', fname_out])
                    end
                    write_netcdf_file_2D_grid(fname_out, i_out, j_out, lon_out, lat_out, inc_angle, data2D, int_Asc, pentad, start_time, end_time, overwrite, Nf, write_ind_latlon, 'scaling', obsnum)
                end 

                if mod((DOY + 2),5) == 0
                    pentad = (DOY + 2)/5;
                    data_out(i,:,:,pentad) = data2D;
                    start_time_p(pentad) = start_time;
                    end_time_p(pentad) = end_time;
                    if print_each_pentad
                        if combine_species_stats
                            fname_out = [fname_out_base_p, '_spALL_p', num2str(pentad,'%2.2d'), '.nc4'];
                        else
                            fname_out = [fname_out_base_p, '_sp', char(species_names(i)),'_p', num2str(pentad,'%2.2d'), '.nc4'];
                        end
                        if (exist(fname_out)==2 && overwrite)
                            disp(['output file exists. overwriting', fname_out])
                        elseif (exist(fname_out)==2 && ~overwrite) 
                            disp(['output file exists. not overwriting. returning'])
                            disp(['writing ', fname_out])
                            return
                        else
                            disp(['creating ', fname_out])
                        end
                        write_netcdf_file_2D_grid(fname_out, i_out, j_out, lon_out, lat_out, inc_angle, data2D, int_Asc, pentad, start_time, end_time, overwrite, Nf, write_ind_latlon, 'scaling', obsnum)
                    end
                end
                o_data_sum(:,:,1:w_days-1)  = o_data_sum(:,:,2:w_days);
                m_data_sum(:,:,1:w_days-1)  = m_data_sum(:,:,2:w_days);
                o_data_sum2(:,:,1:w_days-1) = o_data_sum2(:,:,2:w_days);
                m_data_sum2(:,:,1:w_days-1) = m_data_sum2(:,:,2:w_days);
                m_data_min(:,:,1:w_days-1) = m_data_min(:,:,2:w_days);
                m_data_max(:,:,1:w_days-1) = m_data_max(:,:,2:w_days);
                N_data(:,:,1:w_days-1)  = N_data(:,:,2:w_days);
                o_data_sum(:,:,w_days)  = NaN;
                m_data_sum(:,:,w_days)  = NaN;
                o_data_sum2(:,:,w_days) = NaN;
                m_data_sum2(:,:,w_days) = NaN;
                m_data_min(:,:,w_days) = NaN;
                m_data_max(:,:,w_days) = NaN;
                N_data(:,:,w_days)  = NaN;
                data2D = NaN+0.0.*data2D;
            end              
        end % count >= w_days
    end % day
end % month

% Find the absolute minimum and maximum of the model data over the whole time period

save('data_out_M36_ASCAT_04012015_03312021.mat','data_out', '-v7.3')

if print_all_pentads
    for i = 1:N_species
        data_o = squeeze(data_out(i,:,:,:));

        if combine_species_stats
            fname_out = [fname_out_base_d, '_spALL_all_pentads.nc4'];
        else
            fname_out = [fname_out_base_d,'_sp', char(species_names(i)),'_all_pentads.nc4'];
        end

        write_netcdf_file_2D_grid(fname_out, i_out, j_out, lon_out, lat_out, ...
                  inc_angle, data_o, int_Asc, [1:73], ...  
                  start_time_p, end_time_p, overwrite, ...
                  Nf, write_ind_latlon, 'scaling',...
                  obsnum)
    end
end


% ==================== EOF ==============================================