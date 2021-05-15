load new_bi_all.mat

load sub.mat
load HumanPwrSpctra.mat
load dpth_one_over_fv2.mat %files in directory

bi_manual = bi_all

filename = 'indiv_'
for k=1:length(bi_manual) %for each person
    tempbfrq = []
    
    for j=1:length(bi_manual{1,k})
        tempbfrq = [tempbfrq,bi_manual{1,k}(1,j)-5:bi_manual{1,k}(1,j)+5]
    end
    tempbfrq = tempbfrq( tempbfrq>=1 )
    
    indiv_file = append(filename,string(k))
    indiv_frq = frq(:,:)
    indiv_pow = avgpwr(find(sub==k),:) %well we actually only care about the channels that are this person's!!
    indiv_frq(:,tempbfrq) = []
    indiv_pow(:,tempbfrq) = [] 
    
    save(indiv_file,'indiv_frq','indiv_pow')
 %   cleanfrqs_all{1,k} = indiv_frq
 %   cleanpow_all{1,k} = indiv_pow
end
deepcell = {[dpth(1,1)]}
count = 1
for i=2:length(dpth)
    if dpth(i,1)<dpth(i-1,1) % a new subject
        count = count + 1
        deepcell{1,count} = []
    end
    deepcell{1,count} = [deepcell{1,count},dpth(i,1)]
end

system('r2_fooofcode.py')

[row,col] = find(megaexps)
col = sort(unique(col))
row = sort(unique(row))
cleanexps_2 = zeros([length(row),length(col)])
cleanoffs_2 = zeros([length(row),length(col)])
for r=1:length(row)
    for c=1:length(col)
        cleanexps_2(r,c) = megaexps(row(r,1),col(c,1))
        cleanoffs_2(r,c) = megaoffset(row(r,1),col(c,1))
    end
end
figure()
subplot(2,1,1);imagesc(cleanexps_2);title('exponent R^2, 2x2Hz')
xticks([25 50 75 100 125]);yticks([25 50 75 100 125])
yticklabels([50,100,150,200,250])
xticklabels([50,100,150,200,250])
colorbar; %caxis([0 0.8])
subplot(2,1,2);imagesc(cleanoffs_2);title('offset R^2, 2x2Hz')
xticks([25 50 75 100 125]);yticks([25 50 75 100 125])
yticklabels([50,100,150,200,250])
xticklabels([50,100,150,200,250])
colorbar;%caxis([0 0.8])
        
    

