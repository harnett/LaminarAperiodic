import numpy as np
from scipy.io import loadmat, savemat
from scipy import stats

from fooof import FOOOFGroup
import matplotlib.pyplot as plt

patientcount = 16

bigoffset = []
bigexps = []

stepsize = 50
dim = int(290/stepsize)


megaoffset= np.zeros((290,290))
megaexps = np.zeros((290,290))

dp = loadmat('deepcell.mat')
dp = dp['deepcell'] #dp[0,0] = first person's depths, dp[0,1] = 2nd, and so on.

freq_nparray = []
psds_nparray =[]
for k in range(1,patientcount+1):
    matfile = 'indiv_' + str(k) + '.mat'
    data = loadmat(matfile)
    # Unpack data from dictionary, and squeeze numpy arrays
    freqs = np.squeeze(data['indiv_frq']).astype('float')
    psds = np.squeeze(data['indiv_pow']).astype('float')
    freq_nparray.append(freqs)
    psds_nparray.append(psds) #this lowers the frequency of loading .mat's, anyway..


for i in range(1,290,2):
    for j in range(1,290,2):
        allexps = []
        alloffset = []
        if not (j>(i+2)):
            pass
        else:
            for k in range(1,patientcount+1):
                freqs = freq_nparray[k-1]
                psds = psds_nparray[k-1]
                # ^Note: this also explicitly enforces type as float (type casts to float64, instead of float32)
                #  This is not strictly necessary for fitting, but is for saving out as json from FOOOF, if you want to do that
                fg = FOOOFGroup(peak_threshold=15,peak_width_limits=[3.0, 14.0])#, aperiodic_mode='knee'
                #fg.report(freqs, psds, [1, 290])
                #fg.fit(freqs,psds,[0.2,290])
                fg.fit(freqs,psds,[i,j]) #this was all i could think of... ;_;
                #fg.plot()

                #reportname = str(k) + '_indiv result'
                #fg.save_report(reportname)

                #print(fg.group_results)


                exps = fg.get_params('aperiodic_params', 'exponent')
                allexps.append(exps)

                offset = fg.get_params('aperiodic_params','offset')
                alloffset.append(offset)
            #ok, so for each range, we have 16 sets ofx exponents and 16 sets of y offsets.
            exp_r2 = 0
            off_r2 = 0
            for w in range(0,16):
                #print(w)
                expy = allexps[w]
                offy = alloffset[w]
                slope, intercept, exp_r, p_value, std_err = stats.linregress(dp[0,w],expy)
                exp_r2 += exp_r**2
                slope, intercept, off_r, p_value, std_err = stats.linregress(dp[0,w],offy)
                off_r2 += off_r**2
                #print('off and exp: ',off_r2,exp_r2)
                #ACTUALLY AVERAGE
            exp_r2 = exp_r2/16
            off_r2 = off_r2/16
            #before we reset the Hz bound, add ^ to list we've been keeping.
            megaexps[i-1,j-1] = exp_r2
            megaoffset[i-1,j-1] = off_r2


savemat('megaoffset_2.mat',{'megaoffset':megaoffset})
savemat('megaexps_2.mat',{'megaexps':megaexps})



    #knee = fg.get_params('aperiodic_params','knee')
    #savemat('knee_allpeeps.mat', {'knee' : knee})

#NOW OUTSIDE OF BIG FORLOOP!
#concat everythin.



#the end...?
