clear

% addpath('../../shared/matlab/');
addpath('/discover/nobackup/amfox/current_GEOSldas/GEOSldas/src/Applications/LDAS_App/util/shared/matlab')

run_months = [1:12 1:4];
exp_path = '/discover/nobackup/amfox/Experiments/ASCAT_noscale_test_debug';
exp_run  = {'ASCAT_M36'};
domain   = 'SMAP_EASEv2_M36_GLOBAL';
start_year = [repmat(2016,1,6) repmat(2015,1,6) repmat(2016,1,4)];
end_year   = [repmat(2017,1,6) repmat(2016,1,6) repmat(2017,1,4)];
prefix_out = 'M36_zscore_stats_';
dt_assim   = 3*60*60;
t0_assim   = 0;
obs_param_fname = [exp_path, '/', exp_run{1}, '/output/', domain, '/rc_out/', ...
    '/Y2016/M04/',exp_run{1}, '.ldas_obsparam.20160401_0000z.txt'];
species_names = {'ASCAT_META_SM_A','ASCAT_META_SM_D','ASCAT_METB_SM_A','ASCAT_METB_SM_D'};
combine_species_stats = 1;
hscale = 0.0;
w_days = 75;
Ndata_min = 5;

if isempty(strfind(prefix_out,'M09'))
    convert_grid='EASEv2_M36';
end

[N_obs_param, obs_param ] = read_obsparam(obs_param_fname);

species =[];

for i = 1:length(species_names)
    add_species = obs_param(strcmp(species_names(i),{obs_param.descr})).species;
    species = union(species,add_species);
end

if combine_species_stats
    disp('Calculating stats by combining muiltiple species');
end

if (exist('convert_grid','var'))
    get_model_and_obs_clim_stats_pentads_latlon_v2(species_names, run_months, exp_path, exp_run{1}, domain, start_year, end_year, dt_assim, t0_assim, species, combine_species_stats, obs_param, hscale, w_days, Ndata_min, prefix_out, convert_grid);
else
    get_model_and_obs_clim_stats_pentads_latlon_v2(species_names, run_months, exp_path, exp_run{1}, domain, start_year, end_year, dt_assim, t0_assim, species, combine_species_stats, obs_param, hscale, w_days, Ndata_min, prefix_out);
end