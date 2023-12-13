analysis_name='analysis_first_level';

spm('defaults', 'FMRI');

img_path=['..',filesep,'fMRI_data'];
img_folders=dir([img_path,'\sub*']);
tim_file={'conditions_run01.mat','conditions_run02.mat'};

for sub_num=1:length(img_folders)
    
    %%  initials
    % set up output folders
    path=[img_path, '\' img_folders(sub_num).name ];
    if ~exist(path,'dir')
        continue;
    end
    if exist([path '\' analysis_name],'dir')
        rmdir([path '\' analysis_name],'s')
    end
    mkdir(path,analysis_name);
    out_path=[path '\' analysis_name];
    
    %find the smoothed and normalized data, as well as motion
    %parameters.
    run1_folder=dir([path '\'  'ge_func_3p5x3p5x3p5_270_0004*']);
    run1_file=spm_select ('FPList',[path '\' run1_folder.name '\'], '^swuf.*\.nii');
    run1_file= cellstr(run1_file);
    
    run1_rp=spm_select ('FPList',[path '\'  run1_folder.name '\'], 'art_regression_outliers_and_movement.*\.mat');
    run1_rp=cellstr(run1_rp);
    
    run2_folder=dir([path '\'  'ge_func_3p5x3p5x3p5_270_0005*']);
    run2_file=spm_select ('FPList',[path '\'  run2_folder.name '\'], '^swuf.*\.nii');
    run2_file= cellstr(run2_file);
    
    run2_rp=spm_select ('FPList',[path '\'  run2_folder.name '\'], 'art_regression_outliers_and_movement.*\.mat');
    run2_rp=cellstr(run2_rp);
    
    run1_vector=[path '\' run1_folder.name '\' tim_file{1}];
    run1_vector=cellstr(run1_vector);
    
    run2_vector=[path '\'  run2_folder.name '\' tim_file{2}];
    run2_vector=cellstr(run2_vector);
    %% contrast
    %prepare contrasts
    eve_type={'1SF_OF','2SF_OUF','3SUF_OF','4SUF_OUF','response1','response2','response3','response4'};
    con_name={'1SF_OF','2SF_OUF','3SUF_OF','4SUF_OUF','5SF(OUF-OF)','6OF(SUF-SF)','7SF','8SUF','9OUF(SUF-SF)','10SUF(OUF-OF)','11SUFvsSF','12OUFvsOF','13inter','14OF','15OUF'};
    con_weight=zeros(length(con_name),length(eve_type));
    
    con_weight(1,1)=1;
    con_weight(2,2)=1;
    con_weight(3,3)=1;
    con_weight(4,4)=1;
    con_weight(5,1:4)=[-1,1,0,0];
    con_weight(6,1:4)=[-1,0,1,0];
    con_weight(7,1:4)=[1,1,0,0];
    con_weight(8,1:4)=[0,0,1,1];
    con_weight(9,1:4)=[0,-1,0,1];
    con_weight(10,1:4)=[0,0,-1,1];
    con_weight(11,1:4)=[-1,-1,1,1];
    con_weight(12,1:4)=[-1,1,-1,1];
    con_weight(13,1:4)=[1,-1,-1,1];
    con_weight(14,1:4)=[1,0,1,0];
    con_weight(15,1:4)=[0,1,0,1];
    
    
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
    
    %% 2. generate the SPM.mat file
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    
    for con_len=1:length(con_name)
        matlabbatch{3}.spm.stats.con.consess{con_len}.tcon.name =con_name{con_len} ;
        matlabbatch{3}.spm.stats.con.consess{con_len}.tcon.weights = con_weight(con_len,:);
        matlabbatch{3}.spm.stats.con.consess{con_len}.tcon.sessrep = 'repl';
    end
    
    matlabbatch{3}.spm.stats.con.delete = 0;
    spm_jobman('serial', matlabbatch);
    clear matlabbatch;
end
