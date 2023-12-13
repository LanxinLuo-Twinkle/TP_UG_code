spm('defaults', 'FMRI');
path=['..',filesep,'fMRI_data'];
folders=dir([path,'\sub*']);

for i=1:length(folders)
    
    sub_file=folders(i).name;
    MVPAfolder=dir([path,'\' sub_file '\' '*MVPA_analysis_first_level']);
    
    for j=1:length(MVPAfolder)
        mask_image=spm_select ('FPList',[path '\' sub_file '\' MVPAfolder(j).name '\'], '^wmask.*\.nii'); %normalized mask image
        
        %% accuracy image
        acc_folder=dir([path, '\', sub_file, '\' MVPAfolder(j).name '\decoding*']);
        
        for xx=1:length(acc_folder)
            
            acc_image=spm_select ('FPList',[path '\' sub_file '\' MVPAfolder(j).name '\' acc_folder(xx).name '\'], '^swres_.*\.nii'); %smoothed and masked accuracy images
            acc_image=cellstr(acc_image);
            
            for yy=1:length(acc_image)
                
                cal_images={mask_image;acc_image{yy}};
                out_path=[path '\' sub_file '\' MVPAfolder(j).name '\' acc_folder(xx).name];
                
                %-----------------------------------------------------------------------
                matlabbatch{1}.spm.util.imcalc.input = cellstr(cal_images);
                if yy==1
                    matlabbatch{1}.spm.util.imcalc.output = 'mswres_accuracy_minus_chance';
                elseif yy==2
                    matlabbatch{1}.spm.util.imcalc.output = 'mswres_dprime';
                end
                matlabbatch{1}.spm.util.imcalc.outdir = cellstr(out_path);
                matlabbatch{1}.spm.util.imcalc.expression = '(i1>0.9).*i2';
                matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
                matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
                matlabbatch{1}.spm.util.imcalc.options.mask = 0;
                matlabbatch{1}.spm.util.imcalc.options.interp = 1;
                matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
                
                
                %% do the job
                spm_jobman('serial', matlabbatch);
                clear matlabbatch;
            end
        end
    end
end