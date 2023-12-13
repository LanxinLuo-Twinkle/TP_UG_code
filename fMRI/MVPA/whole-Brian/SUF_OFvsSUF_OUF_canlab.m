basedir = ['..',filesep,'fMRI_data'];
gray_matter_mask = which('gray_matter_mask.img');
sub_fold=dir([basedir,'\sub*']);
SUF_OUF_imgs =[];
SUF_OF_imgs=[];
for n=1:length(sub_fold)
    SUF_OUF_img =filenames(fullfile(basedir, sub_fold(n).name,'\analysis_first_level\','con_0004.nii'));
    SUF_OF_img = filenames(fullfile(basedir, sub_fold(n).name, '\analysis_first_level\','con_0003.nii'));
    SUF_OUF_imgs=[SUF_OUF_imgs;SUF_OUF_img];
    SUF_OF_imgs=[SUF_OF_imgs;SUF_OF_img];
end
data_SUF_OUFvsSUF_OF = fmri_data([SUF_OUF_imgs; SUF_OF_imgs], gray_matter_mask);
data_SUF_OUFvsSUF_OF.Y = [ones(numel(SUF_OUF_imgs),1); -ones(numel(SUF_OF_imgs),1)]; 
% LOSO and save weights
n_folds = [repmat(1:30,1,1) repmat(1:30,1,1)];
n_folds = n_folds(:);
[~, stats_loso_SUF_OUFvsSUF_OF] = predict(data_SUF_OUFvsSUF_OF, 'algorithm_name', 'cv_svm', 'nfolds', n_folds, 'error_type', 'mcr');
ROC_loso = roc_plot(stats_loso_SUF_OUFvsSUF_OF.dist_from_hyperplane_xval, data_SUF_OUFvsSUF_OF.Y == 1, [true(30,1);false(30,1)], 'twochoice','color','r');
stats_loso_SUF_OUFvsSUF_OF.weight_obj.fullpath = fullfile(basedir, 'canlab', 'SUF_OUFvsSUF_OF_loso_unthreshold_weights.nii');
write(stats_loso_SUF_OUFvsSUF_OF.weight_obj);

%% bootstrap
delete(gcp)
parpool(1)
[~, stats_boot_SUF_OUFvsSUF_OF] = predict(data_SUF_OUFvsSUF_OF, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'error_type', 'mcr', 'bootweights', 'bootsamples', 10000,'savebootweights');
%save stats_boot_SUF_OUFvsSUF_OF.mat stats_boot_SUF_OUFvsSUF_OF -v7.3

%load stats_boot_SUF_OUFvsSUF_OF.mat
data_un01 = threshold(stats_boot_SUF_OUFvsSUF_OF.weight_obj, .01,'uncorrected');
data_un01.fullpath = fullfile(basedir, 'canlab', 'SUF_OUFvsSUF_OF_bootstrap_results_un01.nii');
write(data_un01, 'thresh','overwrite');