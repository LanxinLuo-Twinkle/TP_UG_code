clc,clear;
%%  load the data
[design,~,~] = xlsread('all_data.xlsx');
subs         = unique(design(:,1),'stable');
nsub         = length(subs); % number of subjects.

%% load the parameters
[par,~,~]=xlsread('IndPars_fit_m3.xlsx');
par = par(:,2:end);
paras = struct('alpha1',par(:,1)','alpha2',par(:,2)','beta',par(:,3)','tau',par(:,4)');


%% simulation for each subject: absolute fit methods
for n=1:nsub
    clear design_sub
    design_sub = design((design(:,1)==subs(n)),:); %data for a given subj. There is no missing trials in this exp, so we do not need to exclude missing trials
    if n==1
        sim_data   = abs_fit_m3(paras,design_sub,n,1);
    else
        sim_data   = [sim_data;abs_fit_m3(paras,design_sub,n,1)];
    end
end


%%  save data
names={'subid',	'gender','trial','run','conds','offer_pro','offer_self','offer_tp','RT','choice','utility_accept','utility_reject','utility_choose ','utility_unchoose','choice_sim','utility_SF','utility_OF','utility_gSF','utility_gOF'};
commaheader = [names;repmat({','},1,numel(names))];
commaheader=commaheader(:)';
textheader=cell2mat(commaheader);

fid = fopen('title_all_data_sim.csv','w');
fprintf(fid,'%s\n',textheader);
%write out data to end of file
dlmwrite('all_data_sim.csv',sim_data,'-append');

fclose('all');
save sim_data_abs_and_sim2.mat sim_data

