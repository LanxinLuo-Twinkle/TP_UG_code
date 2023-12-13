function MVPA_analysis(C1_run1,C1_run2,C2_run1,C2_run2,C1_name,C2_name,outfolder,ROIfile)

%% initialize TDT & cfg

cfg = decoding_defaults;
cfg.design.unbalanced_data = 'ok'; %if your trial is not equal

C11_len = length(C1_run1);
C12_len = length(C1_run2);
C21_len = length(C2_run1);
C22_len = length(C2_run2);

%% 1. setting beta images, including file names and lables (condition names): edit with SPM.mat file
cfg.files.name=[C1_run1;C2_run1;C1_run2;C2_run2];
cfg.files.descr=[repmat(C1_name,1,C11_len), repmat(C2_name,1,C21_len),repmat(C1_name,1,C12_len),repmat(C2_name,1,C22_len)]';
cfg.files.chunk=[ones(1,C11_len+C21_len),ones(1,C12_len+C22_len)*2]';  %a vector, one chunk number for each file in cfg.files.name. Chunks can be used to keep data together
cfg.files.label=[ones(1,C11_len),-1*ones(1,C21_len),ones(1,C12_len),-1*ones(1,C22_len)]';  %fair as 1 and unfiar as -1, independent of in or out - groups


%% 2. generate design file (cv: cross-validattion)
%design=make_design_cv(cfg);  %OUTPUT: train, test, label.
%cfg.design=design;

cfg.design.train=zeros(C11_len+C21_len+C12_len+C22_len,2); %two folds
cfg.design.test=zeros(C11_len+C21_len+C12_len+C22_len,2);
cfg.design.label=[ones(2,C11_len),-1*ones(2,C21_len),ones(2,C12_len),-1*ones(2,C22_len)]';

cfg.design.train(1:C11_len+C21_len,1)=1; %run1 as train
cfg.design.test(C11_len+C21_len+1:C12_len+C22_len+C11_len+C21_len,1)=1;%run2 as test

cfg.design.train(C11_len+C21_len+1:C12_len+C22_len+C11_len+C21_len,2)=1; %run2 as train
cfg.design.test(1:C11_len+C21_len,2)=1;%run1 as  test

cfg.design.set=ones(1,2);
%% 3. set progress display
cfg.plot_selected_voxels=0; %plot every step
cfg.plot_design = 0; %(default); will plot your design.change 1

%% 4. set the type of analysis that is performed
cfg.analysis='searchlight';% alternatives: 'searchlight', 'wholebrain' ('ROI' does not make sense here);
cfg.searchlight.radius = 4; % set searchlight size in voxels
cfg.decoding.method = 'classification_kernel';%svm

%% 5. set output etc.
cfg.results.output = {'accuracy_minus_chance', 'dprime'};
cfg.results.dir=outfolder; 
cfg.results.overwrite = 1;
cfg.software = 'SPM12';


%% set ROI masks
cfg.files.mask =ROIfile;
cfg.scale.method = 'min0max1';
cfg.scale.estimation = 'all';
[results, cfg] = decoding(cfg);

