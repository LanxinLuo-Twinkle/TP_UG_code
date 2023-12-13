clear;
Mark2=readtable('..\UG_all.xlsx');
root_path=['..',filesep,'fMRI_data'];
folders=dir([root_path,'\sub*']);

for sub_num=1:30 
    path=[root_path, '\' folders(sub_num).name];
    ID = folders(sub_num).name;
    subID=str2num(ID(8:10));
    for run=1:2 
        eve_type={'offer','dec'};
        %% getting onsets
        %% parameters for each run
        
        for typ_num=1:2
            if typ_num==1
                onset= Mark2.rons_offers(Mark2.run==run & Mark2.subid==subID );
                dur=4;
                pname='none';
                pv1=0 ;
                
            elseif typ_num==2
                onset= Mark2.rons_dec(Mark2.run==run & Mark2.subid==subID);
                dur=0;
                pname='Utility';
                pv1= Mark2.utility_cho_uncho(Mark2.run==run & Mark2.subid==subID);
                
            end
            
            
            names{typ_num}=eve_type{typ_num};
            onsets{typ_num}=onset;
            durations{typ_num}=dur;
            pmod(typ_num).name{1}=pname;
            pmod(typ_num).param{1}=pv1;
            pmod(typ_num).poly{1}=1;
            orth{typ_num}=0;
                
            onset=[];
            dur=[];
        end
        
        
        
        run1_path=[path '\'  'ge_func_3p5x3p5x3p5_270_0004'];
        run2_path=[path '\'  'ge_func_3p5x3p5x3p5_270_0005'];
        oup_name=['utility_cho_uncho_dec0s_run0' num2str(run)];
        
        if run==1
           save([run1_path '\' oup_name], 'names', 'onsets', 'durations','pmod','orth');
        elseif run==2
            save([run2_path '\' oup_name], 'names', 'onsets', 'durations','pmod','orth');
            
        end
    end
end