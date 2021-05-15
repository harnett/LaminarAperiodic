def indiv_fooofcode():
    import sys
    import numpy as np
    from scipy.io import loadmat, savemat

    from fooof import FOOOFGroup
    import matplotlib.pyplot as plt

    patientcount = 16

    alloffset = []
    allr2 = []
    allexps = []
    allcfs = []

    for k in range(1,patientcount+1):
        matfile = 'indiv_' + str(k) + '.mat'
        data = loadmat(matfile)

        # Unpack data from dictionary, and squeeze numpy arrays
        freqs = np.squeeze(data['indiv_frq']).astype('float')
        psds = np.squeeze(data['indiv_pow']).astype('float')
        # ^Note: this also explicitly enforces type as float (type casts to float64, instead of float32)
        #  This is not strictly necessary for fitting, but is for saving out as json from FOOOF, if you want to do that
        fg = FOOOFGroup(peak_threshold=7,peak_width_limits=[3, 14])#, aperiodic_mode='knee'
        #fg.report(freqs, psds, [30, 300])
        #fg.fit(freqs,psds,[float(sys.argv[1]),float(sys.argv[2])])
        fg.fit(freqs,psds,[float(sys.argv[1]),float(sys.argv[2])])
        fg.plot()

        reportname = str(k) + '_indiv result'
        fg.save_report(reportname)

        #print(fg.group_results)

        r2 = fg.get_params('r_squared')
        allr2.append(r2)

        exps = fg.get_params('aperiodic_params', 'exponent')
        allexps.append(exps)

        centerfrq = fg.get_params('peak_params','CF')
        allcfs.append(centerfrq)

        offset = fg.get_params('aperiodic_params','offset')
        alloffset.append(offset)

        #knee = fg.get_params('aperiodic_params','knee')
        #savemat('knee_allpeeps.mat', {'knee' : knee})

    #NOW OUTSIDE OF BIG FORLOOP!
    #concat everythin.
    savemat('all_offset.mat',{'all_offset' : alloffset})
    savemat('all_r2.mat', {'all_r2' : allr2})
    savemat('all_exps.mat', {'all_exps' : allexps})
    savemat('all_cfs.mat',{'all_cfs' : allcfs}) #these are cell arrays! I didn't even mean for them to be but heck yea useful

indiv_fooofcode()