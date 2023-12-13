spm('defaults', 'FMRI');
root_path=['..',filesep,'fMRI_data'];
path=[root_path,'\group\analysis_first_level'];
folders=dir([path,'\*con_*']);

for i=1:length(folders)
    
    %% outpath
    con_path=[path ,'\', folders(i).name];
    if exist([con_path,'\group'],'dir')
        rmdir([con_path,'\group'],'s');
    end
    mkdir(con_path,'group');
    out_path=[con_path, '\group'];
    
    %% con images
    con_file=spm_select ('FPList',[con_path '\'], '.*con.*\.nii');
    con_file= cellstr(con_file);
    
    %%  set up the model-----------------------------------------------------------------------
    matlabbatch{1}.spm.stats.factorial_design.dir =cellstr(out_path);
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = con_file;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'pos';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    spm_jobman('serial', matlabbatch);
    clear matlabbatch;
    
end