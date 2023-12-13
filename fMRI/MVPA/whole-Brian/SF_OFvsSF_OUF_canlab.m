basedir = ['..',filesep,'fMRI_data'];
gray_matter_mask = which('gray_matter_mask.img');
sub_fold=dir([basedir,'\sub*']);
SF_OUF_imgs =[];
SF_OF_imgs=[];
for n=1:length(sub_fold)
    SF_OUF_img =filenames(fullfile(basedir, sub_fold(n).name,'\analysis_first_level\','con_0002.nii'));
    SF_OF_img = filenames(fullfile(basedir, sub_fold(n).name, '\analysis_first_level\','con_0001.nii'));
    SF_OUF_imgs=[SF_OUF_imgs;SF_OUF_img];
    SF_OF_imgs=[SF_OF_imgs;SF_OF_img];
end
data_SF_OUFvsSF_OF = fmri_data([SF_OUF_imgs; SF_OF_imgs], gray_matter_mask);
data_SF_OUFvsSF_OF.Y = [ones(numel(SF_OUF_imgs),1); -ones(numel(SF_OF_imgs),1)]; 
%% Training SVM with leave-one-subject-out (LOSO) cross-validation
n_folds = [repmat(1:30,1,1) repmat(1:30,1,1)];
n_folds = n_folds(:);
[~, stats_loso_SF_OUFvsSF_OF] = predict(data_SF_OUFvsSF_OF, 'algorithm_name', 'cv_svm', 'nfolds', n_folds, 'error_type', 'mcr');
ROC_loso = roc_plot(stats_loso_SF_OUFvsSF_OF.dist_from_hyperplane_xval, data_SF_OUFvsSF_OF.Y == 1, [true(30,1);false(30,1)], 'twochoice','color','r');
stats_loso_SF_OUFvsSF_OF.weight_obj.fullpath = fullfile(basedir, 'canlab', 'SF_OUFvsSF_OF_loso_unthreshold_weights.nii');
write(stats_loso_SF_OUFvsSF_OF.weight_obj);