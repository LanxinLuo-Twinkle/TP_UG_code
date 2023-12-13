%% read SUF_OF AND SUF_OUF images
basedir = ['..',filesep,'fMRI_data'];
gray_matter_mask = which('gray_matter_mask.img');
sub_fold=dir([basedir,'\sub*']);
OUF_imgs =[];
OF_imgs=[];
for n=1:length(sub_fold)
    OUF_img =filenames(fullfile(basedir, sub_fold(n).name,'\analysis_first_level\','con_0015.nii'));
    OF_img = filenames(fullfile(basedir, sub_fold(n).name, '\analysis_first_level\','con_0014.nii'));
    OUF_imgs=[OUF_imgs;OUF_img];
    OF_imgs=[OF_imgs;OF_img];
end
data_OUFvsOF = fmri_data([OUF_imgs; OF_imgs], gray_matter_mask);
data_OUFvsOF.Y = [ones(numel(OUF_imgs),1); -ones(numel(OF_imgs),1)];

% LOSO and save weights
n_folds = [repmat(1:30,1,1) repmat(1:30,1,1)];
n_folds = n_folds(:);
[~, stats_loso_OUFvsOF] = predict(data_OUFvsOF, 'algorithm_name', 'cv_svm', 'nfolds', n_folds, 'error_type', 'mcr');
ROC_loso = roc_plot(stats_loso_OUFvsOF.dist_from_hyperplane_xval, data_OUFvsOF.Y == 1, [true(30,1);false(30,1)], 'twochoice','color','r');
stats_loso_OUFvsOF.weight_obj.fullpath = fullfile(basedir, 'canlab_MainE', 'OUFvsOF_loso_unthreshold_weights.nii');
write(stats_loso_OUFvsOF.weight_obj);