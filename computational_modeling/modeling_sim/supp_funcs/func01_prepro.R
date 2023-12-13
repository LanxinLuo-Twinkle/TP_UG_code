#1.1. pre-processing function
prepro_func <- function(d_df, general_info) {
  # Currently class(d_df) == "data.table"
  
  # Use general_info of d_df
  subjs   <- general_info$subjs
  n_subj  <- general_info$n_subj
  t_subjs <- general_info$t_subjs # number of trials for each sub and block
  t_max   <- general_info$t_max
  
  # Initialize (model-specific) data arrays
  choice          <- array(-1, c(n_subj, t_max)) # choice, -1 for missing data
  offer_pro       <- array(-1, c(n_subj, t_max)) # money to the proposer, -1 for missing data
  offer_self      <- array(-1, c(n_subj, t_max)) # money to participants, -1 for missing data
  offer_tp        <- array(-1, c(n_subj, t_max)) # money to third party, -1 for missing data

  data_new <- data.frame('subid'=rep(-1,n_subj*t_max),'trial'=rep(-1,n_subj*t_max),"choice"=rep(-1,n_subj*t_max),"offer_pro"=rep(-1,n_subj*t_max),
                         "offer_self"=rep(-1,n_subj*t_max),"offer_tp"=rep(-1,n_subj*t_max))

  
  # Write from d_df to the data arrays
  for (i in 1:n_subj) {
    subj                        <- subjs[i]
    t                           <- t_subjs[i] #trial number of the current subject
    DT_subj                     <- d_df[d_df$subid == subj]
    
    choice[i, 1:t]              <- DT_subj$choice
    offer_pro[i, 1:t]           <- DT_subj$offer_pro
    offer_self[i, 1:t]          <- DT_subj$offer_self
    offer_tp[i, 1:t]            <- DT_subj$offer_tp
    
  }
  
  # Wrap into a list for Stan
  data_list <- list(
    Ns             = n_subj,
    Ts             = t_max,
    Tsubj          = t_subjs,
    choice         = choice,
    offer_pro      = offer_pro,
    offer_self     = offer_self,
    offer_tp       = offer_tp
  )
  
  
  # write into a data frame for PPC
  data_new$subid                 <- rep(subjs,each=t_max)
  data_new$trial                 <- rep(rep(1:t_max),times=n_subj)
  data_new$choice                <- as.vector(aperm(choice, c(2,1))) #change the order of arrary and then transfer to a vector
  data_new$offer_pro             <- as.vector(aperm(offer_pro, c(2,1)))
  data_new$offer_self            <- as.vector(aperm(offer_self, c(2,1)))
  data_new$offer_tp              <- as.vector(aperm(offer_tp, c(2,1)))

  
  if (general_info$gen_file==1){  #only generate the data file for the main analysis, not for simulation analysis
    write.csv(data_new,file='data_for_cm_all.csv',row.names = FALSE)
  }
  
  # Returned data_list will directly be passed to Stan
  return(data_list)
}
