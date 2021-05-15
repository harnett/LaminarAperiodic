def fooofmodel():    
    import sys
    import numpy as np
    from scipy.io import loadmat, savemat

    from fooof import FOOOFGroup
    import matplotlib.pyplot as plt

    data = loadmat('ModelPowSpctraForFOOOF.mat')

    # Unpack data from dictionary, and squeeze numpy arrays
    freqs = np.squeeze(data['fx']).astype('float')
    psds = np.squeeze(data['avgpwr']).astype('float')
    # ^Note: this also explicitly enforces type as float (type casts to float64, instead of float32)
    #  This is not strictly necessary for fitting, but is for saving out as json from FOOOF, if you want to do that

    # Transpose power spectra, to have the expected orientation for FOOOF
    #psds = psds.T
    fg = FOOOFGroup(peak_threshold=7,peak_width_limits=[3, 14])#, aperiodic_mode='knee'
    #fg.report(freqs, psds, [1, 290])
    #fg.fit(freqs,psds,[0.2,290])
    fg.fit(freqs,psds,[1 , 290])
    fg.plot()
    fg.save_report('modelfits')

    slp = fg.get_params('aperiodic_params', 'exponent')
    off = fg.get_params('aperiodic_params','offset')
    r = fg.get_params('r_squared')

    savemat('slp.mat',{'slp':slp})
    savemat('off.mat', {'off': off})
    savemat('r.mat', {'r': r})
    return
fooofmodel()