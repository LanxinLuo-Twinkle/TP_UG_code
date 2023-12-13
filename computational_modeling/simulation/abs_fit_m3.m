function data = abs_fit_m3(param,design,subn,sampn)
rng('shuffle')
%% parameters
alpha1       = param.alpha1(sampn,subn);
alpha2       = param.alpha2(sampn,subn);
beta          = param.beta(sampn,subn);
tau            = param.tau(sampn,subn);
%% initialisation
data    = zeros(length(design),15);

%% initial setup

utility_accept             = zeros(length(design),1);
utility_reject               = zeros(length(design),1);
utility_choose            = zeros(length(design),1);
utility_unchoose        = zeros(length(design),1);
utility_OF                   = zeros(length(design),1);
utility_SF                   = zeros(length(design),1);
utility_gOF                   = zeros(length(design),1);
utility_gSF                   = zeros(length(design),1);
choice_sim                = zeros(length(design),1);

trial                = design(:,3);
run                = design(:,4);
conds            = design(:,5);
offer_pro       = design(:,6);
offer_self       = design(:,7);
offer_tp         = design(:,8);
choice           = design(:,10);

for nt=1:length(design) % loop over each trial of the block
    
    utility_accept(nt) = offer_self(nt) + alpha1*offer_tp(nt) - alpha2*(beta*max(5 - offer_self(nt),0) + (1-beta)*max(5 - offer_tp(nt),0));
    utility_reject(nt) =  0;
    
    if choice(nt) == 1
        utility_choose(nt) = utility_accept(nt);
        utility_unchoose(nt) = 0;
    else
        utility_choose(nt) = 0;
        utility_unchoose(nt) = utility_accept(nt);
    end
    
    utility_SF(nt) = beta*max(5 - offer_self(nt),0);
    utility_OF(nt) = (1-beta)*max(5 - offer_tp(nt),0);
    utility_gSF(nt) =alpha2*beta*max(5 - offer_self(nt),0);
    utility_gOF(nt) =alpha2*(1-beta)*max(5 - offer_tp(nt),0);
    
    
    cprob(1) = 1/(1+exp(-tau * utility_accept(nt) ) ); %calculates the probability of accepting
    cprob(2) = 1- cprob(1);
    
    c_all(nt)     = find(rand < cumsum(cprob(:)),1); % 1 or 2 generate choice between the two options based on their probabilities
    c_pro(nt)     = cprob(1); %saves the probability of the accepting option
    
    clear cprob
    choice_sim(nt) =  c_all(nt);
end % nt

%% write data into output variable 'data'


data(:,1:10)  = design;
data(:,11)    = utility_accept;
data(:,12)    = utility_reject;
data(:,13)    = utility_choose;
data(:,14)   = utility_unchoose;
data(:,15)   = choice_sim;
data(:,16)    = utility_SF;
data(:,17)    = utility_OF;
data(:,18)   = utility_gSF;
data(:,19)   = utility_gOF;


