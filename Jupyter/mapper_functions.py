import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import numpy as np
import xarray as xr
import re
import warnings

from shapely.errors import ShapelyDeprecationWarning

warnings.filterwarnings("ignore", category=ShapelyDeprecationWarning)

def plot_global(array, saveflag=False, plot_title ='global_plot', units='na', cmin=None, cmax=None, cmap=None):

    # Check if cmin and cmax are None
    if cmin is None:
        # Info for colorbar
        cmin, cmax, cmap = colorbar_info(array)

    # Check if field has positive and negative values
    if cmap is None:
        if cmin < 0:
            cmap = 'RdYlBu_r'
            cmap = plt.get_cmap('RdBu', 16)
        else:
            cmap = 'viridis' 
    
    # Create the plot
    fig = plt.figure(figsize=(10, 6))
    ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree(central_longitude=0))
    # plot grid lines
    gl = ax.gridlines(crs=ccrs.PlateCarree(central_longitude=0), draw_labels=True,
                          linewidth=1, color='gray', alpha=0.5, linestyle='-')
    gl.xlabel_style = {'size': 5, 'color': 'black'}
    gl.ylabel_style = {'size': 5, 'color': 'black'}
    gl.xlocator = mticker.FixedLocator([-180, -135, -90, -45, 0, 45, 90, 135, 179.9])
    ax.tick_params(labelbottom=False, labeltop=False, labelleft=False, labelright=False)

    ax.set_global()
    ax.add_feature(cfeature.LAND, facecolor='lightgray')  # Set the land color to light gray
    ax.add_feature(cfeature.COASTLINE)
    #ax.add_feature(cfeature.BORDERS)

    # scatter data
    sc = ax.scatter(array[:, 1], array[:, 2],
                    c=array[:, 0], s=1, linewidth=0, cmap=cmap, vmin=cmin, vmax=cmax,
                    transform=ccrs.PlateCarree()) 
    # Set the colorbar properties
    cbar = plt.colorbar(sc, ax=ax, orientation="horizontal", pad=.12, fraction=0.04)
    cbar.ax.tick_params(labelsize=6)
    cbar.set_label(units, fontsize=10)

    # Set the axis and title labels
    plt.title(plot_title, fontsize=12)
    ax.text(0.45, -0.1,   'Longitude', fontsize=8, transform=ax.transAxes, ha='left')
    ax.text(-0.08, 0.4, 'Latitude', fontsize=8, transform=ax.transAxes, rotation='vertical', va='bottom')

    if saveflag:
        savename = plot_title+'.png'
        print(" Saving figure as", savename, "\n")
        plt.savefig(savename, dpi = 400)    

     # Show the plot
    plt.show()

def plot_global_tight(array, saveflag=False, plot_title ='global_plot', units='na', cmin=None, cmax=None, cmap=None):

    # Check if cmin and cmax are None
    if cmin is None:
        # Info for colorbar
        cmin, cmax, cmap = colorbar_info(array)

    # Check if field has positive and negative values
    if cmap is None:
        if cmin < 0:
            cmap = 'RdYlBu_r'
            cmap = plt.get_cmap('RdBu_r', 20)
            #cmap = plt.get_cmap('viridis', 4)
        else:
            cmap = 'viridis'
            cmap = plt.get_cmap('viridis', 20)        
    
    # Create the plot
    fig = plt.figure(figsize=(10, 6))
    ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree(central_longitude=0))

    # Set the extent to North America
    ax.set_extent([-180, 180, -60, 90], crs=ccrs.PlateCarree())

    # plot grid lines
    gl = ax.gridlines(crs=ccrs.PlateCarree(central_longitude=0), draw_labels=False,
                          linewidth=1, color='gray', alpha=0.5, linestyle='-')
    gl.xlabel_style = {'size': 5, 'color': 'black'}
    gl.ylabel_style = {'size': 5, 'color': 'black'}
    gl.xlocator = mticker.FixedLocator([-180, -135, -90, -45, 0, 45, 90, 135, 179.9])
    ax.tick_params(labelbottom=False, labeltop=False, labelleft=False, labelright=False)

    # ax.set_global()
    ax.add_feature(cfeature.LAND, facecolor='lightgrey')  # Set the land color to light gray
    ax.add_feature(cfeature.COASTLINE)
    #ax.add_feature(cfeature.BORDERS)

    # scatter data
    sc = ax.scatter(array[:, 1], array[:, 2],
                    c=array[:, 0], s=0.8, linewidth=0, cmap=cmap, vmin=cmin, vmax=cmax,
                    transform=ccrs.PlateCarree()) 
    # Set the colorbar properties
    
    cbar = plt.colorbar(sc, ax=ax, orientation="horizontal", pad=.05, fraction=0.04) #, format=mticker.FormatStrFormatter('%.3f'))
    cbar.set_ticks(np.arange(cmin, cmax+0.000000001, (cmax-cmin)/4))
    cbar.ax.tick_params(labelsize=10)
    cbar.set_label(units, fontsize=12)

    # Set the axis and title labels
    plt.title(plot_title, fontsize=16)
    # ax.text(0.45, -0.1,   'Longitude', fontsize=8, transform=ax.transAxes, ha='left')
    # ax.text(-0.08, 0.4, 'Latitude', fontsize=8, transform=ax.transAxes, rotation='vertical', va='bottom')

    if saveflag:
        savename = re.sub('[^0-9a-zA-Z]+', '_', plot_title) + '.png'
        print(" Saving figure as", savename, "\n")
        plt.savefig(savename, dpi = 600, bbox_inches='tight')    

     # Show the plot
    plt.show()


##
def plot_na(array, saveflag=False, plot_title ='na_plot', units='na'):

    # Info for colorbar
    cmin, cmax, cmap = colorbar_info(array)
    
    # Create the plot
    fig = plt.figure(figsize=(10, 6))
    ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree(central_longitude=0))

    # Set the extent to North America
    ax.set_extent([-140, -50, 15, 60], crs=ccrs.PlateCarree())

    # plot grid lines
    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                    linewidth=1, color='gray', alpha=0.5, linestyle='-')
    gl.xlabel_style = {'size': 5, 'color': 'black'}
    gl.ylabel_style = {'size': 5, 'color': 'black'}
    gl.xlocator = mticker.FixedLocator([-180, -135, -90, -45, 0, 45, 90, 135, 179.9])
    ax.tick_params(labelbottom=False, labeltop=False, labelleft=False, labelright=False)

    ax.coastlines()
    ax.add_feature(cfeature.LAND, facecolor='lightgray')  # Set the land color to light gray
    ax.add_feature(cfeature.BORDERS)

    # scatter data
    sc = ax.scatter(array[:, 1], array[:, 2],
                    c=array[:, 0], s=3, linewidth=0, cmap=cmap, vmin=cmin, vmax=cmax,
                    transform=ccrs.PlateCarree()) 

    # Set the colorbar properties
    cbar = plt.colorbar(sc, ax=ax, orientation="horizontal", pad=.12, fraction=0.04)
    cbar.ax.tick_params(labelsize=6)
    cbar.set_label(units, fontsize=10)

    # Set the axis and title labels
    plt.title(plot_title, fontsize=12)
    ax.text(0.45, -0.1, 'Longitude', fontsize=8, transform=ax.transAxes, ha='left')
    ax.text(-0.08, 0.4, 'Latitude', fontsize=8, transform=ax.transAxes, rotation='vertical', va='bottom')

    if saveflag:
        savename = plot_title+'.png'
        print(" Saving figure as", savename, "\n")
        plt.savefig(savename, dpi=400)

    # Show the plot
    plt.show()


def colorbar_info(array):

    # Compute and print some stats for the data
    # -----------------------------------------
    stdev = np.nanstd(array[:,0])  # Standard deviation
    omean = np.nanmean(array[:, 0]) # Mean of the data
    datmi = np.nanmin(array[:, 0])  # Min of the data
    datma = np.nanmax(array[:, 0])  # Max of the data
    abmm = np.nanmax(np.abs(array[:, 0])) # Abs max of the data

    # Min max for colorbar
    # --------------------
    if np.nanmin(array[:, 0]) < 0:
        cmax = abmm
        cmin = abmm * -1
        cmap = 'RdBu'
    else:
        cmax = datma
        cmin = datmi
        cmap = 'viridis'

    return cmin, cmax, cmap

def plot_global_contour(lon2d, lat2d, field, saveflag=False, plot_title ='global_plot', units='na', cmin=None, cmax=None):

    # Check if cmin and cmax are None
    if cmin is None:
        cmin = np.nanmin(field)
    if cmax is None:
        cmax = np.nanmax(field)

    # Check if field has positive and negative values
    if cmin < 0:
    #    cmax = np.nanmax(np.abs(field))
    #    cmin = -cmax
        cmap = 'RdBu'
    else:
        cmap = 'viridis'

    levels = np.linspace(cmin,cmax,50)
    #levels = np.linspace(0, 1, 50)
    
    # Create the plot
    fig = plt.figure(figsize=(10, 6))
    ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree(central_longitude=0))
    # plot grid lines
    gl = ax.gridlines(crs=ccrs.PlateCarree(central_longitude=0), draw_labels=True,
                          linewidth=1, color='gray', alpha=0.5, linestyle='-')
    gl.xlabel_style = {'size': 5, 'color': 'black'}
    gl.ylabel_style = {'size': 5, 'color': 'black'}
    gl.xlocator = mticker.FixedLocator([-180, -135, -90, -45, 0, 45, 90, 135, 179.9])
    ax.tick_params(labelbottom=False, labeltop=False, labelleft=False, labelright=False)

    ax.set_global()
    ax.add_feature(cfeature.LAND, facecolor='lightgray')  # Set the land color to light gray
    ax.add_feature(cfeature.COASTLINE)
    #ax.add_feature(cfeature.BORDERS)

    # scatter data
    sc = ax.contourf(lon2d, lat2d, field, transform=ccrs.PlateCarree(), cmap=cmap, levels=levels)
    
    # Set the colorbar properties
    cbar = plt.colorbar(sc, ax=ax, orientation="horizontal", pad=.12, fraction=0.04)
    cbar.ax.tick_params(labelsize=6)
    cbar.set_label(units, fontsize=10)

    # Set the axis and title labels
    plt.title(plot_title, fontsize=12)
    ax.text(0.45, -0.1,   'Longitude', fontsize=8, transform=ax.transAxes, ha='left')
    ax.text(-0.08, 0.4, 'Latitude', fontsize=8, transform=ax.transAxes, rotation='vertical', va='bottom')

    if saveflag:
        savename = plot_title+'.png'
        print(" Saving figure as", savename, "\n")
        plt.savefig(savename, dpi = 400)    

     # Show the plot
    plt.show()

def plot_global_tight_pcm(array, saveflag=False, meanflag=False, plot_title ='global_plot', units='na', cmin=None, cmax=None, cmap=None):

    # Read binary files and reshape to correct size
    # The number of rows and columns are in the file name
    lats = np.fromfile('../test_data/EASE2_M36km.lats.964x406x1.double', 
                          dtype=np.float64).reshape((406,964))
    lons = np.fromfile('../test_data/EASE2_M36km.lons.964x406x1.double', 
                          dtype=np.float64).reshape((406,964))
    
    ds = xr.open_dataset('DAv7_M36.inst3_1d_lndfcstana_Nt.20150901.nc4')
    lon = ds['lon']
    lat = ds['lat']
    n_tile = len(lat)
    
    # Convert to numpy array
    lon = lon.values
    lat = lat.values

    # Make an empty array with dimensions of the grid
    grid = np.full((406, 964), np.nan)
    lats_row = lats[:,1]
    lons_col = lons[1,:]

    # Fill the grid with the values from the dataset
    for i in range(n_tile):
    # Find the row and column of the grid
        row = np.abs(lats_row - lat[i]).argmin()
        col = np.abs(lons_col - lon[i]).argmin()

        # Check if row and col are within the valid range of indices for the grid array
        if row < grid.shape[0] and col < grid.shape[1]:
            grid[row, col] = -9998
        else:
            print('Row or column index out of bounds')

    # Put the array values onto the grid
    for i in range(len(array)):
        row = np.abs(lats_row - array[i, 2]).argmin()
        col = np.abs(lons_col - array[i, 1]).argmin()
        if row < grid.shape[0] and col < grid.shape[1]:
            # Check if the value in array[i, 0] is not a NaN
            if not np.isnan(array[i, 0]):
                grid[row, col] = array[i, 0]
        #else:
        #    print('Row or column index out of bounds')   

    # In the special case of having counts we want to have zeros not -9998. We can do this by setting all -9998 to 0 if plot_title contains 'Number' or 'Percent'
    if 'Number' in plot_title or 'Percent' in plot_title:
        grid[grid == -9998] = 0    
    
    # Construct a text string containing the mean and +- standard deviation of non nan values in array[:,0]
    mean = np.nanmean(array[:, 0])
    std = np.nanstd(array[:, 0])

    def format_number(num):
        if abs(num) < 0.01:
            # Use 3 decimal places if the number is less than 0.001
            return '{:.4f}'.format(num)
        elif abs(num) < 1.0:
            # Use 2 decimal places if the number is less than 1
            return '{:.2f}'.format(num)
        else:
            # Use 3 significant figures otherwise
            return '{:.3g}'.format(num)

    textstr = 'Mean = {}±{} {}'.format(format_number(mean), format_number(std), units)

    if 'Relative $\Delta$ StdDev' in plot_title:
        textstr = 'Mean = {:.1f}±{:.1f} {}'.format(mean, std, units)
    
    # Check if cmin and cmax are None
    if cmin is None:
        # Info for colorbar
        cmin, cmax, cmap = colorbar_info(array)

    # Check if field has positive and negative values
    if cmap is None:
        if cmin < 0:
            cmap = plt.get_cmap('RdBu_r', 20).copy()
        else:
            cmap = plt.get_cmap('viridis', 20).copy()
    else:
        cmap = plt.get_cmap(cmap)

    cmap.set_under('lightgrey')        

    # Create the plot
    fig = plt.figure(figsize=(10, 6))
    ax = fig.add_subplot(1, 1, 1, projection=ccrs.PlateCarree(central_longitude=0))

    # Set the extent to North America
    ax.set_extent([-180, 180, -60, 90], crs=ccrs.PlateCarree())

    # plot grid lines
    gl = ax.gridlines(crs=ccrs.PlateCarree(central_longitude=0), draw_labels=False,
                          linewidth=1, color='gray', alpha=0.5, linestyle='-')
    gl.xlabel_style = {'size': 5, 'color': 'black'}
    gl.ylabel_style = {'size': 5, 'color': 'black'}
    gl.xlocator = mticker.FixedLocator([-180, -135, -90, -45, 0, 45, 90, 135, 179.9])
    ax.tick_params(labelbottom=False, labeltop=False, labelleft=False, labelright=False)

    # ax.set_global()
    ax.add_feature(cfeature.LAND, facecolor='white')  # Set the land color to light gray
    ax.add_feature(cfeature.COASTLINE)
    #ax.add_feature(cfeature.BORDERS)

    # scatter data
    #sc = ax.scatter(array[:, 1], array[:, 2],
    #                c=array[:, 0], s=0.8, linewidth=0, cmap=cmap, vmin=cmin, vmax=cmax,
    #                transform=ccrs.PlateCarree())

    sc = ax.pcolormesh(lons, lats, grid, transform=ccrs.PlateCarree(), cmap=cmap, vmin=cmin, vmax=cmax) 

    # Set the colorbar properties
    cbar = plt.colorbar(sc, ax=ax, orientation="horizontal", pad=.05, fraction=0.04) #, format=mticker.FormatStrFormatter('%.3f'))
    cbar.set_ticks(np.arange(cmin, cmax+0.000000001, (cmax-cmin)/4))
    cbar.ax.tick_params(labelsize=10)
    cbar.set_label('({})'.format(units), fontsize=12)

    # Set the axis and title labels
    plt.title(plot_title, fontsize=18)

    if meanflag:
        ax.text(0.38, 0.05, textstr, fontsize=14, transform=ax.transAxes, ha='left')

    if saveflag:
        savename = re.sub('[^0-9a-zA-Z]+', '_', plot_title) + '.png'
        print(" Saving figure as", savename, "\n")
        plt.savefig(savename, dpi = 600, bbox_inches='tight')    

     # Show the plot
    plt.show()