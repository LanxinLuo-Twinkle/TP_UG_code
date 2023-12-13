basedir = ['..',filesep,'fMRI_data'];
gray_matter_mask = which('gray_matter_mask.img');
sub_fold=dir([basedir,'\sub*']);
SUF_imgs =[];
SF_imgs=[];
for n=1:length(sub_fold)
    SUF_img =filenames(fullfile(basedir, sub_fold(n).name,'\analysis_first_level\','con_0008.nii'));
    SF_img = filenames(fullfile(basedir, sub_fold(n).name, '\analysis_first_level\','con_0007.nii'));
    SUF_imgs=[SUF_imgs;SUF_img];
    SF_imgs=[SF_imgs;SF_img];
end
data_SUFvsSF = fmri_data([SUF_imgs; SF_imgs], gray_matter_mask);
data_SUFvsSF.Y = [ones(numel(SUF_imgs),1); -ones(numel(SF_imgs),1)]; 

% LOSO and save weights
n_folds = [repmat(1:30,1,1) repmat(1:30,1,1)];
n_folds = n_folds(:);
[~, stats_loso_SUFvsSF] = predict(data_SUFvsSF, 'algorithm_name', 'cv_svm', 'nfolds', n_folds, 'error_type', 'mcr');
ROC_loso = roc_plot(stats_loso_SUFvsSF.dist_from_hyperplane_xval, data_SUFvsSF.Y == 1, [true(30,1);false(30,1)], 'twochoice','color','r');
stats_loso_SUFvsSF.weight_obj.fullpath = fullfile(basedir, 'canlab_MainE', 'SUFvsSF_loso_unthreshold_weights.nii');
write(stats_loso_SUFvsSF.weight_obj);

%% bootstrap 
delete(gcp)
parpool(1)
[~, stats_boot_SUFvsSF] = predict(data_SUFvsSF, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'error_type', 'mcr', 'bootweights', 'bootsamples', 10000,'savebootweights');
%save stats_boot_SUFvsSF.mat stats_boot_SUFvsSF -v7.3

%load stats_boot_SUFvsSF.mat
data_un01 = threshold(stats_boot_SUFvsSF.weight_obj, .01,'uncorrected');
data_un01.fullpath = fullfile(basedir, 'canlab', 'SUFvsSF_bootstrap_results_un01.nii');
write(data_un01, 'thresh','overwrite');