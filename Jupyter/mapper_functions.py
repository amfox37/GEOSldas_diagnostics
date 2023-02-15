import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import numpy as np

def plot_global(array, saveflag=False, plot_title ='global_plot', units='na'):

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
    ax.coastlines()
    ax.add_feature(cfeature.BORDERS)

    # scatter data
    sc = ax.scatter(array[:, 1], array[:, 2],
                    c=array[:, 0], s=1, linewidth=0,
                    transform=ccrs.PlateCarree()) 
    # Set the colorbar properties
    cbar = plt.colorbar(sc, ax=ax, orientation="horizontal", pad=.12, fraction=0.04,)
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
