% Calculate scaling files for ASCAT wetness fraction
%
% GDL, 11 Sep 2012
% QLiu, Dec 2016
% amfox April 2023

%=====================================================================

clear

% add path to matlab functions in src/Applications/LDAS_App/util/shared/matlab/
addpath('../../shared/matlab/');
                                                                                                    
%======                                                                 
 run_months = [1:12 1:4]; %loop through 1:4 again to get complete pentads

exp_path = '/discover/nobackup/amfox/Experiments/ASCAT_noscale_test_debug';
exp_run  = {'ASCAT_M36'};
domain   = 'SMAP_EASEv2_M36_GLOBAL';

%Start and end year for each month
start_year = [repmat(2016,1,6) repmat(2015,1,6) repmat(2016,1,4)]; %corresp to [1:12 1 2]
end_year   = [repmat(2017,1,6) repmat(2016,1,6) repmat(2017,1,4)]; %runs till end of run_months for end_year

prefix_out = 'M36_zscore_stats_';

dt_assim   = 3*60*60;    % [seconds] land analysis time step,
                         %             same as LANDASSIM_DT in GEOSldas)
t0_assim   =       0;    % [seconds] land analysis "reference" time (offset from 0z), 
                         %             same as LANDASSIM_T0 in GEOSldas (except for units),  
                         %             typically 0 in offline runs and 1.5*60*60 in LADAS

%======

obs_param_fname = [exp_path, '/', exp_run{1}, '/output/', domain, '/rc_out/', ...
    '/Y2016/M04/',exp_run{1}, '.ldas_obsparam.20160401_0000z.txt'];

% List species to use here
species_names = {'ASCAT_META_SM','ASCAT_METB_SM','ASCAT_METC_SM'};

% Decide here if we're combining statitics across multiple species
combine_species_stats = 1; % Calculate combined statistics for all species in species_names if set to 1.

if combine_species_stats
    disp('Calculating stats by combining muiltiple species');
end

%Spatial sampling
hscale = 0.0;          % degrees lat/lon

% Temporal sampling window(days), current hard coded and need to be divisive by 5 and be an odd number
w_days    = 75;  

% Minimum number of data points in a pentad to calculate stats
Ndata_min = 5;

%To limit M09 tiles to administering M36 tiles only (smaller files),
%provide convert_grid
if isempty(strfind(prefix_out,'M09'))
    convert_grid='EASEv2_M36';
end

if (mod(w_days,10) == 0)
    disp('w_days should be 5, 15, 25, 35, ...')
    error('Need an odd number of pentads |xxxxx|xxXxx|xxxxx|')
end
if (mod(w_days, 5) > 0)
    error('Aiming at pentad files')
end

% ------------------------------------------------------------------------

[N_obs_param, obs_param ] = read_obsparam(obs_param_fname);

species =[];

for i = 1:length(species_names)
    add_species = obs_param(strcmp(species_names(i),{obs_param.descr})).species;
    species = union(species,add_species);
end

species
% ------------------

for n=1:length(exp_run)  
    if (exist('convert_grid','var'))
        get_model_and_obs_clim_stats_pentads_latlon( species_names, ...
            run_months, exp_path, exp_run{n}, domain, start_year, end_year, ...
            dt_assim, t0_assim, species, combine_species_stats, obs_param, ...
            hscale, w_days, Ndata_min, prefix_out, convert_grid );
    else
        get_model_and_obs_clim_stats_pentads_latlon( species_names, ...
            run_months, exp_path, exp_run{n}, domain, start_year, end_year, ...
            dt_assim, t0_assim, species, combine_species_stats, obs_param, ...
            hscale, w_days, Ndata_min, prefix_out);
    end
end

% ============= EOF ====================================================