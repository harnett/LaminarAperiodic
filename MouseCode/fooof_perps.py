def fooof_perps():
    import sys
    import numpy as np
    from scipy.io import loadmat, savemat

    from fooof import FOOOFGroup
    import matplotlib.pyplot as plt

    data = loadmat('perps_proper.mat')

    # Unpack data from dictionary, and squeeze numpy arrays
    freqs = np.squeeze(data['fx_regular']).astype('float')
    psds = np.squeeze(data['powa_regular']).astype('float')
    # ^Note: this also explicitly enforces type as float (type casts to float64, instead of float32)
    #  This is not strictly necessary for fitting, but is for saving out as json from FOOOF, if you want to do that

    # Transpose power spectra, to have the expected orientation for FOOOF
    #psds = psds.T
    fg = FOOOFGroup(peak_threshold=4,peak_width_limits=[3, 14])#, aperiodic_mode='knee'
    #fg.report(freqs, psds, [1, 290])
    #fg.fit(freqs,psds,[0.2,290])
    fg.fit(freqs,psds,[float(sys.argv[1]),float(sys.argv[2])])
    fg.plot()
    fg.save_report('perps')

    #print(fg.group_results)


    r2 = fg.get_params('r_squared')
    savemat('p_r2.mat', {'p_r2' : r2})

    exps = fg.get_params('aperiodic_params', 'exponent')
    centerfrq = fg.get_params('peak_params','CF')
    peakheight = fg.get_params('peak_params','PW')
    savemat('p_exps.mat', {'p_exps' : exps})
    savemat('p_cfs.mat', {'p_cfs' : centerfrq})
    savemat('p_peakheight.mat',{'p_peakheight' : peakheight})

    offset = fg.get_params('aperiodic_params','offset')
    savemat('p_offs.mat', {'p_offs' : offset})


    #knee = fg.get_params('aperiodic_params','knee')
    #savemat('knee_allpeeps.mat', {'knee' : knee})
fooof_perps()