function h = getFuncData(h)

M = zeros(length(h.cIX_abs),length(h.t_start:h.t_stop));
for ii = 1:length(h.cIX_abs)
    ichosen = h.cIX_abs(ii);
%     igroup = gIX(ii);
    
    
    F = [];
    Fneu = [];
    for j = 1:numel(h.dat.Fcell)
        F    = cat(2, F, h.dat.Fcell{j}(ichosen, :));
        Fneu = cat(2, Fneu, h.dat.FcellNeu{j}(ichosen, :));
    end
    coefNeu = 0.7 * ones(1, size(F,1));
    
    dF                  = F - bsxfun(@times, Fneu, coefNeu(:));
    y = double(dF(h.t_start:h.t_stop));%my_conv_local(medfilt1(double(F), 3), 3);
    y_m = y-mean(y);
    M(ii,:) = y_m/10000;
    
end
h.M = M;
% 
% %% make dFF matrix for all ROIs
% 
% h.dat.numROIs = numel(h.dat.stat);
% h.dat.numSessions = numel(h.dat.Fcell);
% 
%     F = [];
%     Fneu = [];
%     for j = 1:numel(h.dat.Fcell)
%         F    = cat(2, F, h.dat.Fcell{j});
%         Fneu = cat(2, Fneu, h.dat.FcellNeu{j});
%     end
% 
%  coefNeu = 0.7 * ones(1, size(F,1));    
%  dF = F - bsxfun(@times, Fneu, coefNeu(:));
%  %%
%  
% %  dFF = (dF-mean(dF,2))./mean(dF,2);%?
%  
%  im = dFF;
%  im(find(isnan(dFF))) = 0;
%  im(309,:) = 0;
%  h.dF = dF;
%  h.dFn = zscore(dF,0,2);

 
end