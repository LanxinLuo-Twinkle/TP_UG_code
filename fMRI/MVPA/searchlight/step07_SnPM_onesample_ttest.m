spm('defaults','fMRI');
spm_jobman('initcfg');
clear matlabbatch;
Tvalue=3.3962; 

path=['..',filesep,'MVPA'];
MVPA_folders=dir([path,'\*MVPA_analysis_first_level']);
for k=1:length(MVPA_folders)
    MVPA_path=[path ,'\', MVPA_folders(k).name];
    decoding_folders=dir([MVPA_path,'\decoding*']);
    for i=1:length(decoding_folders)
        decoding_path=[MVPA_path ,'\', decoding_folders(i).name];
        ms_folders=dir([decoding_path,'\*mswre*']);
        for m=1:length(ms_folders)
            ms_path=[decoding_path,'\', ms_folders(m).name];
            if exist([ms_path,'\SnPM'],'dir')
                rmdir([ms_path,'\SnPM'],'s'); 
            end
            mkdir(ms_path,'SnPM');
            out_path=[ms_path, '\SnPM'];
            ms_file=spm_select ('FPList',[ms_path '\'], '.*mswre.*\.nii');
            ms_file= cellstr(ms_file);
            
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.dir = cellstr(out_path);
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.P = ms_file;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.cov = struct('c', {}, 'cname', {});
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.nPerm = 5000;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.vFWHM = [0 0 0];
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.bVolm = 1;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.ST.ST_U = Tvalue;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.tm.tm_none = 1;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.im = 1;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.em = {''};
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalc.g_omit = 1;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.gmsca.gmsca_no = 1;
            matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.glonorm = 1;
            
            matlabbatch{2}.spm.tools.snpm.cp.snpmcfg(1) = cfg_dep('MultiSub: One Sample T test on diffs/contrasts: SnPMcfg.mat configuration file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPMcfg'));
            
            matlabbatch{3}.spm.tools.snpm.inference.SnPMmat(1) = cfg_dep('Compute: SnPM.mat results file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPM'));
            matlabbatch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = NaN;
            matlabbatch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = 0.05;
            matlabbatch{3}.spm.tools.snpm.inference.Tsign = 1;
            matlabbatch{3}.spm.tools.snpm.inference.WriteFiltImg.WF_no = 0;
            matlabbatch{3}.spm.tools.snpm.inference.Report = 'MIPtable';
            
            spm_jobman('serial', matlabbatch);
            clear matlabbatch;
        end
    end
end