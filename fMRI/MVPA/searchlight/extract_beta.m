function beta_imgs = extract_beta(subpath,betafile,pattern)
fun = @(s)~cellfun('isempty',strfind(betafile(:,2),s));
out = cellfun(fun,pattern,'UniformOutput',false);
idx = all(horzcat(out{:}),2);

betas = betafile(idx,1);
beta_imgs=fullfile(subpath,betas);
