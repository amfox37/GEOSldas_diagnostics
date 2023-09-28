def read_obs_param(fname):
    # Get observation parameters
    # Format as in module enkf_types, subroutine write_obs_param
    #
    # Gabrielle De Lannoy  - 26 Oct 2011
    #
    #  1 Dec 2011 - reichle: minor modifications and check-in to CVS
    #
    #  8 Jun 2017 - reichle: added "flistpath" and "flistname"
    #
    # ------------------------------------------------------------------
    with open(fname, 'r') as fid:
        print('Reading', fname)

        N_obs_param = int(fid.readline().strip())
        obs_param = [{} for i in range(N_obs_param)]

        for i in range(N_obs_param):
            obs_param[i]['descr'] = fid.readline().strip()
            obs_param[i]['species'] = float(fid.readline().strip())
            obs_param[i]['orbit'] = float(fid.readline().strip())  # 1=A, 2=D
            obs_param[i]['pol'] = float(fid.readline().strip())  # 1=H, 2=V
            obs_param[i]['N_ang'] = float(fid.readline().strip())
            obs_param[i]['ang'] = [float(x) for x in fid.readline().split()]
            obs_param[i]['freq'] = float(fid.readline().strip())
            obs_param[i]['FOV'] = float(fid.readline().strip())
            obs_param[i]['FOV_units'] = fid.readline().strip()
            obs_param[i]['assim'] = fid.readline().strip()
            obs_param[i]['scale'] = fid.readline().strip()
            obs_param[i]['getinnov'] = fid.readline().strip()
            obs_param[i]['RTM_ID'] = float(fid.readline().strip())
            obs_param[i]['bias_Npar'] = float(fid.readline().strip())
            obs_param[i]['bias_trel'] = float(fid.readline().strip())
            obs_param[i]['bias_tcut'] = float(fid.readline().strip())
            obs_param[i]['nodata'] = float(fid.readline().strip())
            obs_param[i]['varname'] = fid.readline().strip()
            obs_param[i]['units'] = fid.readline().strip()
            obs_param[i]['path'] = fid.readline().strip()
            obs_param[i]['name'] = fid.readline().strip()
            obs_param[i]['scalepath'] = fid.readline().strip()
            obs_param[i]['scalename'] = fid.readline().strip()
            obs_param[i]['flistpath'] = fid.readline().strip()
            obs_param[i]['flistname'] = fid.readline().strip()
            obs_param[i]['errstd'] = float(fid.readline().strip())
            obs_param[i]['std_normal_max'] = float(fid.readline().strip())
            obs_param[i]['zeromean'] = fid.readline().strip()
            obs_param[i]['coarsen_pert'] = fid.readline().strip()
            obs_param[i]['xcorr'] = float(fid.readline().strip())
            obs_param[i]['ycorr'] = float(fid.readline().strip())
            obs_param[i]['adapt'] = float(fid.readline().strip())
            
            # remove leading and trailing quotes from strings
            obs_param[i]["descr"] = obs_param[i]["descr"][1:-1]
            obs_param[i]["varname"] = obs_param[i]["varname"][1:-1]
            obs_param[i]["path"] = obs_param[i]["path"][1:-1]
            obs_param[i]["name"] = obs_param[i]["name"][1:-1]
            obs_param[i]["units"] = obs_param[i]["units"][1:-1]
            obs_param[i]["scalepath"] = obs_param[i]["scalepath"][1:-1]
            obs_param[i]["scalename"] = obs_param[i]["scalename"][1:-1]
            obs_param[i]["flistpath"] = obs_param[i]["flistpath"][1:-1]
            obs_param[i]["flistname"] = obs_param[i]["flistname"][1:-1]

    print(f"Done reading obs_param for {N_obs_param} species")
    return N_obs_param, obs_param