load perps_proper.mat

sia = []
sub = []
for i=0:(size(powa_regular,1)-1) %here, 23 is the number of chans.
    sia(1,i+1) = mod(i,23)+1
    sub(i+1,1) = floor(i/23)+1
end
dpth = sia'
%so I have to save the files as mindiv_12.mat, and
%it has files indiv_frq and indiv_pow.


filename = 'mindiv_'
for k=1:19 %for each person
    
    indiv_file = append(filename,string(k))
    indiv_frq = fx_regular(:,:)
    indiv_pow = powa_regular(find(sub==k),:) 
    
    save(indiv_file,'indiv_frq','indiv_pow')
 %   cleanfrqs_all{1,k} = indiv_frq
 %   cleanpow_all{1,k} = indiv_pow
end

mdeepcell = {[dpth(1,1)]}
count = 1
for i=2:length(dpth)
    if dpth(i,1)<dpth(i-1,1) % a new subject
        count = count + 1
        mdeepcell{1,count} = []
    end
    mdeepcell{1,count} = [mdeepcell{1,count},dpth(i,1)]
end
save('mdeepcell')

system('mouse_r2fooofcode.py')

load megaoffset_2
load megaexps_2
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
subplot(2,1,1);imagesc(cleanexps_2);title('mouse exponent R^2, 50x50Hz')
xticks([25 50 75 100 125]);yticks([25 50 75 100 125])
yticklabels([50,100,150,200,250])
xticklabels([50,100,150,200,250])
colorbar; %caxis([0 0.8])
subplot(2,1,2);imagesc(cleanoffs_2);title('mouse offset R^2, 50x50Hz')
xticks([25 50 75 100 125]);yticks([25 50 75 100 125])
yticklabels([50,100,150,200,250])
xticklabels([50,100,150,200,250])
colorbar;%caxis([0 0.8])
        