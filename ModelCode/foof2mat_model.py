def foof2mat_model():
    import sys
    from scipy.io import loadmat, savemat

    import sklearn
    from scipy import io
    import scipy
    import numpy as np
    from fooof import FOOOF
    import neurodsp
    import matplotlib.pyplot as plt
    import pacpy
    import h5py
    import matplotlib
    from matplotlib import lines

    import math

    from neurodsp import spectral

    # FOOOF imports: get FOOOF & FOOOFGroup objects
    from fooof import FOOOFGroup

    dat = hdf5storage.loadmat(str(sys.argv[1]))
    frq_ax = np.linspace(0, 500, 5001)  #dat["fx"][0]
    pwr_spectra = dat['avgpwr']  #dat["powall"]

    #pwr_spectra=x['x']
    # Initialize a FOOOFGroup object - it accepts all the same settings as FOOOF
    fg = FOOOFGroup(peak_threshold=7,peak_width_limits=[3, 14])#, aperiodic_mode='knee'

    frange = (1, 290)

    # Fit a group of power spectra with the .fit() method# Fit a
    #  The key difference (compared to FOOOF) is that it takes a 2D array of spectra
    #     This matrix should have the shape of [n_spectra, n_freqs]
    fg.fit(frq_ax, pwr_spectra, frange)

    slp = fg.get_params('aperiodic_params', 'exponent')
    off = fg.get_params('aperiodic_params','offset')
    r = fg.get_params('r_squared')

    savemat('slp.mat',{'slp':slp})
    savemat('off.mat', {'off': off})
    savemat('r.mat', {'r': r})
    return

foof2mat_model()