analysis_name='MVPA_analysis_first_level';
spm('defaults', 'FMRI');
img_path=['..',filesep,'fMRI_data'];
img_folders=dir([img_path,'\sub*']);
tim_file={'conditions_run01_MVPA_event40and4.mat','conditions_run02_MVPA_event40and4.mat'};
for sub_num=1:length(img_folders)
    path=[img_path, '\' img_folders(sub_num).name ];
    if ~exist(path,'dir')
        continue;
    end
    
    if exist([path '\' analysis_name],'dir')
        rmdir([path '\' analysis_name],'s')
    end
    mkdir(path,analysis_name);
    out_path=[path '\' analysis_name];
    
    
    run1_folder=dir([path '\'  'ge_func_3p5x3p5x3p5_270_0004*']);
    run1_file=spm_select ('FPList',[path '\' run1_folder.name '\'], '^u.*\.nii');
    run1_file= cellstr(run1_file);
    run1_rp=spm_select ('FPList',[path '\' run1_folder.name '\'], '^art_regression_outliers_and_movement.*\.mat');
    run1_rp=cellstr(run1_rp);
    
    run2_folder=dir([path '\'  'ge_func_3p5x3p5x3p5_270_0005*']);
    run2_file=spm_select ('FPList',[path '\'  run2_folder.name '\'], '^u.*\.nii');
    run2_file= cellstr(run2_file);
    run2_rp=spm_select ('FPList',[path '\'  run2_folder.name '\'], '^art_regression_outliers_and_movement.*\.mat');
    run2_rp=cellstr(run2_rp);
    
    run1_vector=[path '\' run1_folder.name '\' tim_file{1}];
    run1_vector=cellstr(run1_vector);
    
    run2_vector=[path '\'  run2_folder.name '\' tim_file{2}];
    run2_vector=cellstr(run2_vector);
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(out_path);
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = run1_file;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi =run1_vector;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = run1_rp;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = run2_file;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi =run2_vector;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg =run2_rp;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    spm_jobman('serial', matlabbatch);
    clear matlabbatch;
end

