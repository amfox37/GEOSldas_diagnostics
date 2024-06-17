% This script computes the stats against sparse network INSITU data

clear

% addpath('/discover/nobackup/amfox/metop_sm_GEOSldas/GEOSldas/src/Applications/LDAS_App/util/shared/matlab/')
% addpath('/gpfsm/dnb34/amfox/GEOSldas_diagnostics/Jupyter/Matlab_functions')
addpath /discover/nobackup/qliu/gdelanno_RTM/MATLAB_LDASSA/
addpath /home/qliu/projects/matlab_code/SMAP/

INSITU_tag ='CalVal_M33'; % 'USCRN', 'Oznet', 'Msnet' , 'SMOSM', 'CalVal_M33', 'SCAN??'

add_anomR = 1;  % no need to compute anom R

fout_path = '/discover/nobackup/amfox/matlab/SMAP/';

if contains(INSITU_tag, 'CalVal')
    rzmc_tag = '';
elseif strcmp(INSITU_tag, 'Oznet') || strcmp(INSITU_tag, 'SMOSM')
    rzmc_tag = 'c3smv';
else
    if  strcmp(INSITU_tag, 'Msnet')
        rzmc_tag = 'c123smv';
    else
        rzmc_tag = 'c1234smv';
    end
end

exp_run_name= {...
        'DAv7_M36_MULTI_type_13_comb_fp_scaled'; ...
        'OLv7_M36_ASCAT_type_13_comb_fp'
     };

kkk = 1;

% tmp mat file to store the time series
fout_name = [fout_path,'/',exp_run_name{kkk},'_',INSITU_tag, '_SM_3h_',rzmc_tag,'_6yr_']

if exist([fout_name,'raw_timeseries.mat'],'file')
    
    load([fout_name,'raw_timeseries.mat'])
    
else
    
    % read INSITU coord file
    [INSITU_lat, INSITU_lon, INSITU_id] = get_INSITU_coord(INSITU_tag);
    
    if strcmp(INSITU_tag, 'SCAN')
        INSITU_path = '/discover/nobackup/qliu/merra_land/DATA/SCAN/data/PROCESSED_202305_QL/';
    elseif strcmp(INSITU_tag, 'USCRN')
        INSITU_path = '/discover/nobackup/qliu/merra_land/DATA/USCRN/data/PROCESSED_202305/';
    elseif strcmp(INSITU_tag, 'Oznet')
        INSITU_path = '/discover/nobackup/qliu/merra_land/DATA/Murrumbidgee/QLiu_202211/data/PROCESSED/';
    elseif strcmp(INSITU_tag, 'Msnet')
        INSITU_path = '/discover/nobackup/qliu/merra_land/DATA/Oklahoma_Mesonet/data/PROCESSED_201805/';
    elseif strcmp(INSITU_tag, 'SMOSM')
        INSITU_path = '/discover/nobackup/qliu/merra_land/DATA/ISMN/data/PROCESSED_20230101/SMOSMANIA/';
    elseif contains(INSITU_tag, 'CalVal')
        INSITU_path = '/discover/nobackup/qliu/merra_land/DATA/CalVal_insitu/SMAP_refpix/202104/';
    else
        error(['do not recognize ', INSITU_tag ]);
    end
    
    exp_path = ['/discover/nobackup/amfox/Experiments/',exp_run_name{kkk}];

    exp_run= exp_run_name{kkk};

    domain = 'SMAP_EASEv2_M36_GLOBAL';

    out_collection = '.SMAP_L4_SM_gph.';

    start_time.year  = 2015;
    start_time.month = 4;
    start_time.day   = 1;
    start_time.hour  = 1;
    start_time.min   = 30;
    start_time.sec   = 0;
    
    end_time.year  =2021;
    end_time.month = 4; 
    end_time.day   = 1;
    end_time.hour  = start_time.hour;
    end_time.min   = start_time.min;
    end_time.sec   = start_time.sec;
    
    start_time = get_dofyr_pentad(start_time);
    end_time   = get_dofyr_pentad(end_time);
    
    file_tag = 'ldas_tile_xhourly_out';
    
    if contains(file_tag, 'daily')
        dtstep = 86400;
    else
        dtstep = 10800;
    end
    
    % file INSITU site corresponded tile index
    
    fname_tilecoord = [ exp_path, '/', exp_run, '/output/', domain, '/rc_out/', ...
        exp_run, '.ldas_tilecoord.bin'];
    
    tile_coord = read_tilecoord(fname_tilecoord);
    
    tc = tile_coord;
    
    max_distance = .1;
    
    clear ind_tile
    
    for i=1:length(INSITU_id)
        
        this_lat = INSITU_lat(i);
        this_lon = INSITU_lon(i);
        
        distance = (( this_lat - tc.com_lat) .^2 + ...
            ( this_lon - tc.com_lon) .^2     );
        
        ind_tile(i) = find(min(distance) == distance);
        
        distance_min(i) = distance(ind_tile(i));
        
        if distance(ind_tile(i)) > max_distance
            
            disp(['could not find tile for In Situ station ', INSITU_id(i)])
            disp(['distance=', num2str(distance(ind_tile(i))), ...
                ' exceeds max_distance=', num2str(max_distance) ])
            
            ind_tile(i) = NaN;
            
        end
    end
    
    % eliminate In Situ stations for which tile could not be found
    
    INSITU_id(    isnan(ind_tile) ) = [];
    INSITU_lat(   isnan(ind_tile) ) = [];
    INSITU_lon(   isnan(ind_tile) ) = [];
    distance_min( isnan(ind_tile) ) = [];
    
    ind_tile(   isnan(ind_tile) ) = [];
    
    % -----------------------------------------------------------------------
    % read time series of tavg fields
    clear tile_coord tc LDAS_sm_org LDAS_prcp_org
    
        
        % re-read tilecoord file for each run in case the tile orders are different
        
        fname_tilecoord = [ exp_path,'/', exp_run, '/rc_out/',exp_run, '.ldas_tilecoord.bin'];
        
        if ~exist(fname_tilecoord,'file')
            fname_tilecoord = [ exp_path, '/', exp_run, '/output/', domain, '/rc_out/', ...
                exp_run, '.ldas_tilecoord.bin'];
        end
        
        clear tile_coord tc
        
        tile_coord = read_tilecoord(fname_tilecoord);
        
        tc = tile_coord;
        
        clear ind_tile
        
        for i=1:length(INSITU_id)
            
            this_lat = INSITU_lat(i);
            this_lon = INSITU_lon(i);
            
            distance = (( this_lat - tc.com_lat) .^2 + ...
                ( this_lon - tc.com_lon) .^2     );
            
            ind_tile(i) = find(min(distance) == distance);
            
        end
        
        date_time = start_time;
        
        t_ind = 0;
        
        while 1
            
            if (date_time.year ==end_time.year   && ...
                    date_time.month==end_time.month  && ...
                    date_time.day  ==end_time.day    )
                break
            end
            
            t_ind = t_ind + 1;
            
            date_time_vec(t_ind) = date_time;
            date_time_string = get_date_time_string(date_time,file_tag);
            
            % load LDAS ens_avg
            
            file_ext = '.nc4';
            
            fname = [exp_path, exp_run, '/output/', domain,          ...
                    '/cat/ens_avg',                                       ...
                    '/Y',   num2str(date_time.year, '%4.4d'),         ...
                    '/M',   num2str(date_time.month,'%2.2d'),         ...
                    '/', exp_run, out_collection,                          ...
                    date_time_string, 'z',file_ext];
                
            if ~exist(fname,'file')
                fname = strrep(fname,'/ens_avg/','/ens0000/');
            end

            if ~exist(fname,'file')
                fname = [exp_path, '/', exp_run, '/output/', domain,         ...
                        '/cat/ens_avg',                                       ...
                        '/Y',   num2str(date_time.year, '%4.4d'),         ...
                        '/M',   num2str(date_time.month,'%2.2d'),         ...
                        '/', exp_run, out_collection,                         ...
                        date_time_string(1:8), file_ext];
            end

            if ~exist(fname,'file')
                fname = strrep(fname,'/ens_avg/','/ens0000/');
            end
            % read data
            disp(fname)
            clear tile_data_tmp
            tile_data_tmp = ncread(fname, 'sm_surface');
            if size(tile_data_tmp,2) > 1 && dtstep == 10800
                 ind_hour = ceil((date_time.hour+1)/3.);
            else
                 ind_hour = 1;                    
            end
            LDAS_sm_org(t_ind,1,:) = tile_data_tmp(ind_tile,ind_hour);  %sfmc
            clear tile_data_tmp
            tile_data_tmp = ncread(fname, 'sm_rootzone');
            LDAS_sm_org(t_ind,2,:) = tile_data_tmp(ind_tile,ind_hour); 
            clear tile_data_tmp

            tile_data_tmp = ncread(fname, 'surface_temp');
            LDAS_st_org(t_ind,1,:) = tile_data_tmp(ind_tile,ind_hour);
            clear tile_data_tmp

            tile_data_tmp = ncread(fname, 'soil_temp_layer1');
            LDAS_st_org(t_ind,2,:) = tile_data_tmp(ind_tile,ind_hour);
            clear tile_data_tmp

            tile_data_tmp = ncread(fname,'precipitation_total_surface_flux');
            LDAS_prcp_org(t_ind,1,:) = tile_data_tmp(ind_tile,ind_hour); 
            clear tile_data_tmp
                
            date_time = augment_date_time(dtstep, date_time);
            clear fname
        end
        
    
    % read INSITU data
    
    clear INSITU_st INSITU_sm date_time_vec1 INSITU_prcp
    
    for i=1:length(INSITU_id)
        
        INSITU_id_string = INSITU_id{i};
        
        if strcmp(INSITU_tag, 'USCRN')
            tag1 = [INSITU_tag,'_'];
            tmp_tag = '_2009_2023';
        elseif strcmp(INSITU_tag, 'Oznet')
            tag1 = '';
            tmp_tag = '_2015_2022';
        elseif strcmp(INSITU_tag, 'Msnet')
            tag1 = ['Mesonet','_'];
            tmp_tag = '_201504_201804';
        elseif strcmp(INSITU_tag, 'SMOSM')
            tag1 = '';
            tmp_tag = '_2010_2022';
        elseif contains(INSITU_tag, 'CalVal')
            tag1 = '';
            tmp_tag = '_201504_202103';
        else
            tag1 = [INSITU_tag,'_'];
            tmp_tag = '';
        end
        
        if contains(INSITU_tag, 'CalVal')
            fname_tmp = [INSITU_path, '/', tag1,INSITU_id_string,tmp_tag];
        else
            fname_tmp = [INSITU_path, '/',INSITU_id{i},'/', tag1,INSITU_id_string,tmp_tag];
        end
        clear tmp_tag tag1
        
        if contains(file_tag, 'daily')
            data_ext = '1d';
        else
            if contains(INSITU_tag, 'CalVal')
                data_ext = '1h';
            else
                data_ext = '3h';
            end
        end
        
        fname = [fname_tmp,'_',data_ext, '.mat'];
        disp(['loading ', fname])
        load(fname);
        
        if contains(file_tag, 'daily')
            
            if strcmp(INSITU_tag, 'USCRN')
                Sdata = Udata_1d; clear Udata_1d
            else
                Sdata = Sdata_1d; clear Sdata_3d
            end
        else
            if strcmp(INSITU_tag, 'USCRN')
                Sdata = Udata_3h; clear Udata_3h
            elseif contains(INSITU_tag, 'CalVal')
                Sdata = regular_data;
            else
                Sdata = Sdata_3h; clear Sdata_3h
            end
        end
        
        if strcmp(INSITU_tag, 'Msnet')
            INSITU_sm(:,:,i) = Sdata(:,10:12);
            INSITU_st(:,:,i) = Sdata(:,13:15);
        elseif strcmp(INSITU_tag, 'SMOSM')
            INSITU_sm(:,:,i) = Sdata(:, 9:12);
            INSITU_st(:,:,i) = Sdata(:,13:16);
        elseif contains(INSITU_tag, 'CalVal')
            INSITU_sm(:,:,i) = Sdata(:,10 :11);
            INSITU_st(:,:,i) = Sdata(:,12) + 273.15;
            INSITU_prcp(:,:,i) = Sdata(:,9);
        else
            INSITU_sm(:,:,i) = Sdata(:,10:14);
            INSITU_st(:,:,i) = Sdata(:,15:19);
        end
        
        if i==1
            date_time_vec1.year   = Sdata(:, 1);
            date_time_vec1.month  = Sdata(:, 2);
            date_time_vec1.day    = Sdata(:, 3);
            date_time_vec1.hour   = Sdata(:, 4);
            date_time_vec1.min    = Sdata(:, 5);
            date_time_vec1.sec    = Sdata(:, 6);
            date_time_vec1.doy    = Sdata(:, 7);
            date_time_vec1.pentad = Sdata(:, 8);
        end
        
        clear Sdata
        
    end
    
    start_time = date_time_vec(1);
    end_time_tmp   = date_time_vec(end);
    
    if contains(file_tag, 'daily')
        
        ind_start_time = intersect(intersect(find(date_time_vec1.year == start_time.year), ...
            find(date_time_vec1.month == start_time.month)),  ...
            find(date_time_vec1.day == start_time.day));
        
        ind_end_time   = intersect(intersect(find(date_time_vec1.year == end_time_tmp.year), ...
            find(date_time_vec1.month == end_time_tmp.month)),  ...
            find(date_time_vec1.day == end_time_tmp.day));
    else
        
        ind_start_time = intersect(intersect(intersect(find(date_time_vec1.year == start_time.year), ...
            find(date_time_vec1.month == start_time.month)),  ...
            find(date_time_vec1.day == start_time.day)), ...
            find((abs(date_time_vec1.hour - start_time.hour))==min((abs(date_time_vec1.hour - start_time.hour)))));
        
        ind_end_time   = intersect(intersect(intersect(find(date_time_vec1.year == end_time_tmp.year), ...
            find(date_time_vec1.month == end_time_tmp.month)),  ...
            find(date_time_vec1.day == end_time_tmp.day)), ...
            find((abs(date_time_vec1.hour - end_time_tmp.hour))==min((abs(date_time_vec1.hour - end_time_tmp.hour)))));
        
        
    end
    
    if contains(INSITU_tag,'CalVal')
        ind_t = [ind_start_time:dtstep/3600:ind_end_time];
    else
        ind_t = [ind_start_time:ind_end_time];
    end
    
    INSITU_sm_tmp = INSITU_sm(ind_t,:,:);
    INSITU_st_tmp = INSITU_st(ind_t,:,:);
    
    if contains(INSITU_tag,'CalVal') && dtstep == 10800
        INSITU_prcp_tmp = INSITU_prcp(ind_t,:,:);
        for i = 1:length(ind_t)
            INSITU_sm_tmp(i,:,:) = nanmean(INSITU_sm(ind_t(i)-1:(ind_t(i)+1),:,:),1);
            INSITU_st_tmp(i,:,:) = nanmean(INSITU_st(ind_t(i)-1:(ind_t(i)+1),:,:),1);
            INSITU_prcp_tmp(i,:) = nanmean(INSITU_prcp(ind_t(i)-1:(ind_t(i)+1),:,:),1);
        end
        INSITU_prcp_tmp(INSITU_prcp_tmp < -1e-5) = NaN;
        INSITU_prcp = INSITU_prcp_tmp;
        clear INSITU_prcp_tmp
    end
    
    INSITU_sm_tmp(INSITU_st_tmp < 277.16) = NaN;
    INSITU_sm_tmp(INSITU_sm_tmp < 1e-4) = NaN;
    
    INSITU_sm = INSITU_sm_tmp;
    INSITU_st = INSITU_st_tmp; 

    clear INSITU_sm_tmp INSITU_st_tmp
    
    % -----------------------------------------------------------
    % add fields to INSITU_sm
    
    % c12smv  (weighted average of c1smv and c2smv)
    % c123smv (weighted average of c1smv and c2smv and c3smv)
    % ...
    
    if strcmp(INSITU_tag, 'Msnet')
        tavg_tag_INSITU = {'c1smv';'c2smv';'c3smv'};
        
        ind_tmp = [1  2  3  ];    % c1smv, c2smv, ..., c5smv
        w_tmp   = [2  10 24  ];    % corresponding layer depths in inches
        
        tmpstr  = '123';
    elseif strcmp(INSITU_tag, 'SMOSM')
        tavg_tag_INSITU = {'c1smv';'c2smv';'c3smv';'c4smv'};
        
        ind_tmp = [1  2  3  4];    % c1smv, c2smv, ..., c5smv
        w_tmp   = [3  3  8 16 ];    % corresponding layer depths in inches
        
        tmpstr  = '1234';
        
    else
        
        tavg_tag_INSITU = {'c1smv';'c2smv';'c3smv';'c4smv';'c5smv'};
        
        ind_tmp = [1 2 3   4 5 ];    % c1smv, c2smv, ..., c5smv
        w_tmp   = [  3  3  8 16 10 ];    % corresponding layer depths in inches
        
        tmpstr  = '12345';
        
    end
    
    if ~contains(INSITU_tag, 'CalVal')
        w_mat_tmp = ones( size(INSITU_sm,1), 1) * w_tmp;
        
        for k=1:size(INSITU_sm,3)
            w_mat_tmp3d(:,:,k) = w_mat_tmp;
        end
        
        for j=2:length(ind_tmp)
            % compute weighted average over cXsmv
            INSITU_sm(:,end+1,:) = ...
                sum( INSITU_sm(:,ind_tmp(1:j),:).*w_mat_tmp3d(:,1:j,:), 2) / ...
                sum(w_tmp(1:j));
            
            tavg_tag_INSITU{end+1} = [ 'c', tmpstr(1:j), 'smv'];
        end
        
        % only keep surface and selected rootzone SM for INSITU_sm
        % the following 2 lines should be changed together
        
        if strcmp(INSITU_tag, 'Oznet') || strcmp(INSITU_tag, 'SMOSM')
            rzmc_tag = 'c3smv';
        else
            if contains(file_tag, 'daily')
                rzmc_tag = 'c1234smv';
            else
                if strcmp(INSITU_tag, 'Msnet')
                    rzmc_tag = 'c123smv';
                else
                    rzmc_tag = 'c1234smv';
                end
                %rzmc_tag = 'c3smv';
            end
        end
        
        ind_tmp = find(strcmp(tavg_tag_INSITU, rzmc_tag));
        
        INSITU_sm(:,setxor([1 ind_tmp], [1:size(INSITU_sm,2)]),:) = [];
        
    end
    
    %INSITU_sm = permute(INSITU_sm, [1, 3,2]);
    
    % Minum points for statistics (R, RMSE, etc)
    
    if contains(file_tag, 'daily')
        Nmin = 200;
    else
        Nmin = 480;
    end
    
    save([fout_name,'raw_timeseries.mat'])
    
end

for it = 1:length(date_time_vec)
    doy_vec(it) = date_time_vec(it).dofyr;
    year_vec(it) = date_time_vec(it).year;
    month_vec(it) = date_time_vec(it).month;
    day_vec(it) = date_time_vec(it).day;
end

% Compute SM skills

nv = 2;
nn = size(LDAS_sm_org,3);
nc = size(LDAS_sm_org,4);

R   = NaN*ones(nn,nv,nc);
RLO = NaN*ones(nn,nv,nc) ;
RUP = NaN*ones(nn,nv,nc);

if add_anomR
    anomR   = NaN*ones(nn,nv,nc);
    anomRLO = NaN*ones(nn,nv,nc);
    anomRUP = NaN*ones(nn,nv,nc);
end

Bias   = NaN*ones(nn,nv,nc);
BiasLO = NaN*ones(nn,nv,nc);
BiasUP = NaN*ones(nn,nv,nc);

absBias = NaN*ones(nn,nv,nc);
absBiasLO = NaN*ones(nn,nv,nc);
absBiasUP = NaN*ones(nn,nv,nc);

RMSE =   NaN*ones(nn,nv,nc);
ubRMSE =  NaN*ones(nn,nv,nc);
ubRMSELO = NaN*ones(nn,nv,nc);
ubRMSEUP = NaN*ones(nn,nv,nc);

for kk = kkk % 1:length(exp_run)
    
    clear LDAS_sm
    
    LDAS_sm(:,1,:) = LDAS_sm_org(:,1,:);
    LDAS_sm(:,2,:) = LDAS_sm_org(:,2,:);  %rzmc
    LDAS_sm(LDAS_sm == 0) = NaN;
    
    %Cross mask data
    LDAS_sm(isnan(INSITU_sm)) = NaN;
    INSITU_sm(isnan(LDAS_sm)) = NaN;
    
    for i = 1:size(LDAS_sm,3)
        for j = 1:size(LDAS_sm,2)
            
            tmpdata = [INSITU_sm(:,j,i), LDAS_sm(:,j,i)];
            [ stats, stats_tags ] = get_validation_stats( tmpdata, 1 , 'complete', ...
                1, [1:2], Nmin, 1 );
            
            N_data = sum(all(~isnan(tmpdata),2));
            nodata_val = -9999;
            nodata_tol =  1E-4;
            
            stats(abs(stats-nodata_val)<nodata_tol ) = NaN;
            stats(stats == 0 ) = NaN;
            
            R(i,j)   = stats(strcmp(stats_tags,'R'));
            RLO(i,j) = stats(strcmp(stats_tags,'RLO')) - R(i,j) ;
            RUP(i,j) = stats(strcmp(stats_tags,'RUP')) - R(i,j);
            
            Bias(i,j)   = -stats(strcmp(stats_tags,'bias'));
            BiasLO(i,j) = -stats(strcmp(stats_tags,'CI_bias')) ;
            BiasUP(i,j) =  stats(strcmp(stats_tags,'CI_bias')) ;
            
            absBias(i,j) =  abs(stats(strcmp(stats_tags,'bias')));
            absBiasLO(i,j) = -stats(strcmp(stats_tags,'CI_bias')) ;
            absBiasUP(i,j) =  stats(strcmp(stats_tags,'CI_bias')) ;
            
            RMSE(i,j) =     sqrt( stats(strcmp(stats_tags,'MSE')) );
            RMSELO(i,j) = -sqrt(stats(strcmp(stats_tags,'CI_MSE'))) ;
            RMSEUP(i,j) =  sqrt(stats(strcmp(stats_tags,'CI_MSE'))) ;
            ubRMSE(i,j) =   sqrt(stats(strcmp(stats_tags,'MSE')) - stats(strcmp(stats_tags,'bias')).^2);
            ubRMSELO(i,j) = -sqrt(stats(strcmp(stats_tags,'CI_MSE'))+stats(strcmp(stats_tags,'MSE')) - ...
                stats(strcmp(stats_tags,'bias')).^2)+ubRMSE(i,j);
            ubRMSEUP(i,j) =  sqrt(stats(strcmp(stats_tags,'CI_MSE'))+stats(strcmp(stats_tags,'MSE')) - ...
                stats(strcmp(stats_tags,'bias')).^2)-ubRMSE(i,j);
            
            if add_anomR
                
                insitu_data = INSITU_sm(:,j,i);
                model_data  = LDAS_sm(:,j,i);
                
                % cross mask data
                insitu_data(isnan(model_data)) = NaN;
                model_data(isnan(insitu_data)) = NaN;
                
                % window of temporal smoothing
                Nday_window = 31; % days
                Nday_shift = (Nday_window-1)/2;
                
                % minumum data requirement for computing the daily climatology
                Nmin_day = 240 ; % 8 perday *30 days for one clim window
                
                disp('computing anomalies...')
                
                clear dofyr_list
                for dofyr = 1:365
                    if dofyr <= 15
                        dofyr_list(:,dofyr) = [1:dofyr+Nday_shift 365-(Nday_shift-dofyr):365];
                    elseif dofyr >= 351
                        dofyr_list(:,dofyr) = [dofyr-Nday_shift:365 1:Nday_shift-(365-dofyr)];
                    else
                        dofyr_list(:,dofyr) = [dofyr-Nday_shift : dofyr+Nday_shift];
                    end
                end
                
                for doy = 1:365
                    
                    ind = [];
                    for id = 1:length(dofyr_list(:,doy))
                        ind = [ind, find(doy_vec(:) == dofyr_list(id,doy))'];
                    end
                    
                    tmp = insitu_data(ind);
                    tmp = tmp(~isnan(tmp));
                    if length(tmp) >= Nmin_day
                        tmp = mean(tmp);
                    else
                        tmp = NaN;
                    end
                    insitu_clim(doy) = tmp; clear tmp
                    
                    tmp = model_data(ind);
                    tmp = tmp(~isnan(tmp));
                    if length(tmp) >= Nmin_day
                        tmp = mean(tmp);
                    else
                        tmp = NaN;
                    end
                    model_clim(doy) = tmp; clear tmp
                    
                end
                
                model_anom = NaN * ones(size(model_data));
                insitu_anom = NaN * ones(size(model_data));
                
                for doy = 1:366
                    ind = find(doy_vec(:) == doy);
                    if ~isempty(ind)
                        insitu_anom(ind) = insitu_data(ind) - insitu_clim(min(365,doy));
                        model_anom(ind) = model_data(ind) - model_clim(min(365,doy));
                    end
                end
                
                clear stats stats_tags
                [stats, stats_tags] = get_validation_stats(...
                    [insitu_anom model_anom], 1, 'complete', 1, [1:2], Nmin, 1 );
                
                nodata_val = -9999;
                nodata_tol =  1E-4;
                
                stats(abs(stats-nodata_val)<nodata_tol ) = NaN;
                stats(stats == 0 ) = NaN;
                
                
                anomR(i,j)   = stats(strcmp(stats_tags,'R'));
                anomRLO(i,j) = stats(strcmp(stats_tags,'RLO')) - anomR(i,j) ;
                anomRUP(i,j) = stats(strcmp(stats_tags,'RUP')) - anomR(i,j);
                
            end
        end
    end
end

clear LDAS_sm LDAS_sm_org LDAS_prcp_org INSITU_sm INSITU_prcp

disp('writing output ...')
save([fout_name,'stats.mat']);
