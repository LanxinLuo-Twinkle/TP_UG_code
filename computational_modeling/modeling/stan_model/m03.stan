//The model3

data {//these variable names should be consistent with input data names
  int<lower=1> Ns; // define sub number
  int<lower=1> Ts; // define maximum trial number
  int<lower=1, upper=Ts> Tsubj[Ns]; //trial number for each sub
  int choice[Ns, Ts];        //choice,1=accept,2=reject, choice is input as an integer.
  real offer_pro[Ns, Ts];   //money to the proposer
  real offer_self[Ns, Ts]; //money to participants
  real offer_tp[Ns, Ts];  //money to third party
}

transformed data {
}

parameters {
// Declare all parameters as vectors for vectorizing
  // Hyper(group)-parameters
  vector[4] mu_pr; //mean of the parameters,4 paras
  vector<lower=0>[4] sigma; //variance of the parameters, 4 paras

  // Subject-level raw parameters (for Matt trick)
  vector[Ns] alpha1_pr;  // alpha1: weights for the money to dummy player
  vector[Ns] alpha2_pr;  // alpha2: weights for the inequality aversion
  vector[Ns] beta_pr;  // beta: weights for the trade off inequality between (5-Ms) and (5-Mo)
  vector[Ns] tau_pr;    // tau: Inverse temperature
}

transformed parameters {
  // Transform subject-level raw parameters
  real<lower=0, upper=10> alpha1[Ns];
  real<lower=0, upper=10> alpha2[Ns];
  real<lower=0, upper=1> beta[Ns];
  real<lower=0, upper=10> tau[Ns];

  for (i in 1:Ns) {
    alpha1[i] = Phi_approx(mu_pr[1] + sigma[1] * alpha1_pr[i]) * 10;
    alpha2[i] = Phi_approx(mu_pr[2] + sigma[2] * alpha2_pr[i]) * 10;
    beta[i] = Phi_approx(mu_pr[3] + sigma[3] * beta_pr[i]) * 1;
    tau[i]    = Phi_approx(mu_pr[4] + sigma[4] * tau_pr[i]) * 10;
  }
}

model {
  // Hyperparameters
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.5);

  // individual parameters
  alpha1_pr ~ normal(0, 1.0);
  alpha2_pr ~ normal(0, 1.0);
  beta_pr ~ normal(0, 1.0);
  tau_pr    ~ normal(0, 1.0);

  for (i in 1:Ns) {
    // Define values
    vector[2] prob;       // probability of chosing accept
    real prob_1;        // a temporal variable
      
    
    for (t in 1:Tsubj[i]) { //loop over the trial number of each subject. Therefore, skipping the non-responsed trials.
      real util; // Utility for 'accept' option

      // we need only compute the U of 'accpet', since when rejecting, all are 0s, and U equals 0.
       util = offer_self[i,t] + alpha1[i]*offer_tp[i,t] - alpha2[i]*(beta[i]*fmax(5 - offer_self[i,t],0) + (1-beta[i])*fmax(5 - offer_tp[i,t],0));
       prob[1] = 1 / (1 + exp(-tau[i] * util)); // compute the prob of choosing 'accept' here.
       prob_1 = prob[1];
       prob[2] = 1 - prob_1;

      // Sampling statement,computing the likelihood
      choice[i, t] ~ categorical(prob);

    } // end of t loop
  } // end of i loop
}

generated quantities {
  // For group level parameters
  real<lower=0, upper=10> mu_alpha1;
  real<lower=0, upper=10> mu_alpha2;
  real<lower=0, upper=1> mu_beta;
  real<lower=0, upper=10> mu_tau;

  //real Uc[Ns, Ts];   //value of choosen option; only for the winning model
  //real Unc[Ns, Ts]; // vlaue of unchosen option; only for the winning model
  //real prob_acc[Ns, Ts]; // probability of accepting; only for the winning model

  // For log likelihood calculation
  real log_lik[Ns];

  // For posterior predictive check
  //real y_pred[Ns, Ts];  // only for the winning model.

  // Set all posterior predictions to 0 (avoids NULL values); only for winning model
 // for (i in 1:Ns) {
 //   for (t in 1:Ts) {
 //     Uc[i, t] = -999;
//      Unc[i, t] = -999;
 //     y_pred[i, t] = -1;
 //   }
 // }
  mu_alpha1 = Phi_approx(mu_pr[1]) * 10;
  mu_alpha2 = Phi_approx(mu_pr[2]) * 10;
  mu_beta = Phi_approx(mu_pr[3]) * 1;
  mu_tau    = Phi_approx(mu_pr[4]) * 10;


  { // local section, this saves time and space
    for (i in 1:Ns) {
      // Define values
      vector[2] prob;       // probability of chosing accept
      real prob_1;        // a temporal variable     
      
      log_lik[i] = 0.0;

      for (t in 1:Tsubj[i]) {
        
      real util; // Utility for 'accept' option

      // we need only compute the U of 'accpet', since when rejecting, all are 0s, and U equals 0.
       util = offer_self[i,t] + alpha1[i]*offer_tp[i,t] - alpha2[i]*(beta[i]*fmax(5 - offer_self[i,t],0) + (1-beta[i])*fmax(5 - offer_tp[i,t],0));
       prob[1] = 1 / (1 + exp(-tau[i] * util)); // compute the prob of choosing 'accept' here.
       prob_1 = prob[1];
       prob[2] = 1 - prob_1;
       
       //prob_acc[i,t] = prob_1; // only for winning model
       
        // the following are only for winning model
       // if(choice[i,t]==1) {//accept
      //    Uc[i,t]  = util;
     //    Unc[i,t] = 0; // util of rejecting is always 0
    //  } else { //reject
    //    Uc[i,t]  = 0;// util of rejecting is always 0
   //    Unc[i,t] = util; 
  //  }

        // Calculate log likelihood
         log_lik[i] += categorical_lpmf(choice[i, t] | prob);
        
        // generate posterior prediction for current trial
        // y_pred[i, t]  = categorical_rng(softmax(util*tau[i])); //only for winning model

      } // end of t loop
    } // end of i loop
  } // end of local section
}


