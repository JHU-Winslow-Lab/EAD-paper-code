/*       ----------------------------------------------------

	 NOTICE OF COPYRIGHT AND OWNERSHIP OF SOFTWARE
	 Copyright 2003, The Johns Hopkins University
	 School of Medicine. All rights reserved.

	 Name of Program: Local Control Model 
	 Version: Documented Version, C
	 Date: November 2003

	 --------------------------------------------------

	 mpi_master - routines that control computations
	              in all processes

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <memory.h>

#include "parameters.h"
//#include "parameters_fcn_fru.h"
 
#if USE_MPI
#include <mpi.h>
#endif
 
// --------------------------------------------------------------------------

/* For master process: */

/* 
   void send_calc_fru_flux

   Have slave processes run calc_fru_avg and send results to the master.

*/

void send_calc_fru_flux(double FRUdep_states[Nstates_FRUdep],
			double *Jxfer, double *Jtr, double *ICa, double *Ito2)
{
  int msg=MSG_CALC_FRU_FLUX;
  int i;
  double num_stat[6],total_num[6];
  double Cai,CaNSR,V,Jtr_local,Jxfer_local,sum_CaSS_local,sum_CaJSR_local;
  double ICa_numerator,NIto2_Open,ICa_local,Ito2_local;
  double VF_over_RT, VFsq_over_RT, exp_2VFRT,exp_VFRT;

#if USE_MPI
  MPI_Bcast(&msg,1,MPI_INT,0,MPI_COMM_WORLD);
#endif

  V = FRUdep_states[index_frudep_V];
  Cai = FRUdep_states[index_frudep_Cai];
  CaNSR = FRUdep_states[index_frudep_CaNSR];

  VF_over_RT=V/RT_over_F;
  VFsq_over_RT=(1000.0*Faraday)*VF_over_RT;
  exp_VFRT = exp(VF_over_RT);
  exp_2VFRT = exp_VFRT*exp_VFRT;

  //printf("NFRU_local=%d\n",NFRU_local);

  if (NFRU_local>0) {
    calc_fru_flux_local(NFRU_local,LType_state_local,Ito2_state_local,FRU_states_local,num_stat);
  } 
  else {
    for(i=0;i<6;i++)
      num_stat[i]=0;
  }

#if USE_MPI
  for(i=0;i<5;i++)
    total_num[i]=0;

  MPI_Reduce(num_stat,total_num,5,MPI_DOUBLE,MPI_SUM,0,MPI_COMM_WORLD);

  sum_CaSS_local=total_num[0];
  sum_CaJSR_local=total_num[1];
  NIto2_Open=total_num[4];

#else
  sum_CaSS_local=num_stat[0];
  sum_CaJSR_local=num_stat[1];
  total_num[2]=num_stat[2];
  total_num[3]=num_stat[3];
  NIto2_Open=num_stat[4];
#endif

  // Compute actual currents
  if (fabs(V)<1.e-6) { // First order Taylor expansion
    ICa_numerator=total_num[2]-total_num[3]*Cao*0.341; 
    ICa_local = PCa*2.0*1000.0*Faraday*ICa_numerator;
    ICa_local = ICa_local/Acap;		// divide by uF(Acap) to get current normalized to surface area
    Ito2_local = ((double)NIto2_Open)*PCl*1000.0*Faraday*(Clo-Cli);
    Ito2_local = Ito2_local/Acap;	// divide by uF(Acap) to get current normalized to surface area
  } else {
    ICa_numerator=total_num[2]*exp_2VFRT-total_num[3]*Cao*0.341; 
    ICa_local = PCa*4.0*VFsq_over_RT*ICa_numerator/(exp_2VFRT-1.0); 
    ICa_local = ICa_local/Acap;		// divide by uF(Acap) to get current normalized to surface area
    Ito2_local = ((double)NIto2_Open)*PCl*VFsq_over_RT*(Cli-Clo*exp_VFRT)/(1.0 - exp_VFRT);
    Ito2_local = Ito2_local/Acap;	// divide by uF(Acap) to get current normalized to surface area
  }

  Jtr_local = (((double)NFRU_sim)*CaNSR - sum_CaJSR_local)/tautr;
  Jxfer_local = (sum_CaSS_local - ((double)NFRU_sim*(double)Nclefts_FRU)*Cai)/tauxfer;

  *Jxfer=NFRU_scale*Jxfer_local;
  *Jtr=NFRU_scale*Jtr_local;
  *ICa=NFRU_scale*ICa_local;
  *Ito2=NFRU_scale*Ito2_local;
}

/* 
   void send_calc_fru_avg(double state[N],double otherstate[Nother])

   Have slave processes run calc_fru_avg and send results to the master.

*/

void send_calc_fru_avg(double state[N],double otherstate[Nother])
{
  int msg=MSG_CALC_FRU_AVG; 
  double CaSS,CaJSR,CaTOT_SS,CaTOT_JSR;
  double JRyR,PRyR_Open,PNorm_Mode,PnotVinact,PLType_Open,PIto2_Open;
  double NRyR_ready; // converted to double from int
  double num_stat[11];
  int i;

#if USE_MPI
  double total_num[11];

  MPI_Bcast(&msg,1,MPI_INT,0,MPI_COMM_WORLD);
#endif

  if (NFRU_local>0) {
    calc_fru_avg_local(num_stat,NFRU_local,FRU_states_local,LType_state_local,RyR_state_local,Ito2_state_local);
  } else {
    for(i=0;i<11;i++)
      num_stat[i]=0;
  }

#if USE_MPI
  for(i=0;i<11;i++)
    total_num[i]=0;

  MPI_Reduce(num_stat,total_num,11,MPI_DOUBLE,MPI_SUM,0,MPI_COMM_WORLD);

  CaSS=total_num[0];
  CaJSR=total_num[1];
  JRyR=total_num[2];
  PRyR_Open=total_num[3];
  NRyR_ready=total_num[4];
  CaTOT_SS=total_num[5];
  CaTOT_JSR=total_num[6];
  PNorm_Mode=total_num[7];
  PnotVinact=total_num[8];
  PLType_Open=total_num[9];
  PIto2_Open=total_num[10];
#else
  CaSS=num_stat[0];
  CaJSR=num_stat[1];
  JRyR=num_stat[2];
  PRyR_Open=num_stat[3];
  NRyR_ready=num_stat[4];
  CaTOT_SS=num_stat[5];
  CaTOT_JSR=num_stat[6];
  PNorm_Mode=num_stat[7];
  PnotVinact=num_stat[8];
  PLType_Open=num_stat[9];
  PIto2_Open=num_stat[10];
#endif

  otherstate[index_CaSSavg]  = CaSS/(double)(NFRU_sim*Nclefts_FRU);
  otherstate[index_CaJSRavg] = CaJSR/(double)(NFRU_sim);
  otherstate[index_JRyRtot] = JRyR*NFRU_scale*VSS/Vmyo;
  otherstate[index_PRyR_Open]  = PRyR_Open/(double)(NRyRs_per_cleft*Nclefts_FRU*NFRU_sim);
  otherstate[index_PRyR_ready]  = (double)(NRyR_ready)/(double)(NRyRs_per_cleft*Nclefts_FRU*NFRU_sim);
  otherstate[index_CaTOT2] =1.e6*((CaTOT_SS*VSS + CaTOT_JSR*VJSR)*NFRU_scale 
				  + state[index_CaNSR]*VNSR  
				  + state[index_Cai]*Vmyo
				  * (1.0 + CMDNtot/(KmCMDN+state[index_Cai]) + EGTAtot/(KmEGTA+state[index_Cai])) 
				  + (state[index_LTRPNCa]*LTRPNtot + state[index_HTRPNCa]*HTRPNtot)*Vmyo );  //femtomoles 
  otherstate[index_PNorm_Mode] = PNorm_Mode/(double)(NFRU_sim*Nclefts_FRU*NLType_per_cleft);
  otherstate[index_PnotVinact] = PnotVinact/(double)(NFRU_sim*Nclefts_FRU*NLType_per_cleft);
  otherstate[index_PLType_Open] = PLType_Open/(double)(NFRU_sim*Nclefts_FRU*NLType_per_cleft);
  otherstate[index_PIto2_Open] = PIto2_Open/(double)(NFRU_sim*Nclefts_FRU);
  otherstate[index_CaJSRtot] = 1.e6*CaTOT_SS*VSS*NFRU_scale;
  otherstate[index_CaSStot] = 1.e6*CaTOT_JSR*VJSR*NFRU_scale;
}

/* 
   void initialize_mpi_state

   Send initial state to slave processes

*/
void initialize_mpi_state(double FRU_states[NFRU_sim_max][Nstates_FRU],
			  int LType_state[NFRU_sim_max][Nclefts_FRU][NLType_per_cleft][Nindepstates_LType],
			  int RyR_state[NFRU_sim_max][Nclefts_FRU][NRyRs_per_cleft],
			  int Ito2_state[NFRU_sim_max][Nclefts_FRU],
			  int mti[NFRU_sim_max],
			  unsigned long mt[NFRU_sim_max][mtN+1])
{
#define test_fru 2

#if USE_MPI
  int NFRU_local_sent; 
  MPI_Request request[500]; // Max 500/6 procs
  MPI_Status status;
  MPI_Status statusa[500];
  int msg;
  int reqno,p;
  int ok=1;
  int tag;
#endif
  int i,iFRU,icleft;
  int NFRU_local_sent_total;

  //printf("%d procs used\n",procs);

  if (procs>1) {
#if USE_MPI
    NFRU_local_sent=NFRU_sim/procs;
    NFRU_local_sent_total=NFRU_local_sent*(procs-1);

    msg=MSG_INIT_FRU; // initialize FRUs
    reqno=0;
    tag=1;
    
    // init FRU command
    MPI_Bcast(&msg,1,MPI_INT,0,MPI_COMM_WORLD);
    
    // NFRU_local:s to be sent may not be identical, hence we do not use
    // Bcast, even if we are using the same NFRU_local for each process. 
    for(p=1;p<procs;p++) {
      // first receive number of FRU:s
      MPI_Isend(&NFRU_local_sent,1,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
      reqno++;
    }
    MPI_Waitall(reqno,request,statusa);
    
    for(i=0;i<NFRU_local_sent;i++) {
      reqno=0;
      
      for(p=1;p<procs;p++) {
        iFRU=(p-1)*NFRU_local_sent+i;
        //printf("iFRU %d assigned to proc %d\n",iFRU,p);
        
        tag=i*11+p*1000; // i:th element for p:th process


#if SIMPLEDEBUG
        // This is for testing purposes
	MPI_Isend(&LType_state[test_fru][0][0][0],Nclefts_FRU*NLType_per_cleft*Nindepstates_LType,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&RyR_state[test_fru][0][0],Nclefts_FRU*NRyRs_per_cleft,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&Ito2_state[test_fru][0],Nclefts_FRU,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&FRU_states[test_fru][0],Nstates_FRU,MPI_DOUBLE,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&mti[test_fru],1,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&mt[test_fru][0],mtN,MPI_UNSIGNED_LONG,p,tag,MPI_COMM_WORLD,&request[reqno]);
	reqno++;
#else
	MPI_Isend(&LType_state[iFRU][0][0][0],Nclefts_FRU*NLType_per_cleft*Nindepstates_LType,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&RyR_state[iFRU][0][0],Nclefts_FRU*NRyRs_per_cleft,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&Ito2_state[iFRU][0],Nclefts_FRU,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&FRU_states[iFRU][0],Nstates_FRU,MPI_DOUBLE,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&mti[iFRU],1,MPI_INT,p,tag,MPI_COMM_WORLD,&request[reqno]);
	tag++; reqno++;
	MPI_Isend(&mt[iFRU][0],mtN,MPI_UNSIGNED_LONG,p,tag,MPI_COMM_WORLD,&request[reqno]);
	reqno++;
#endif
      }
      MPI_Waitall(reqno,request,statusa);
    }
#endif
  } 
  else {
    NFRU_local_sent_total=0;
  }
    
  // assign extra FRUs to the master
  if (NFRU_sim>NFRU_local_sent_total) {
    int FRU_start;
    
    FRU_start=NFRU_local_sent_total;
    NFRU_local=NFRU_sim-FRU_start;

    printf("0: NFRU_local=%d\n",NFRU_local);

#if NOMEMCPY
    // copy states into a local copy also for the master
    for(iFRU=0;iFRU<NFRU_local;iFRU++) {
      //printf("iFRU %d assigned to master\n",iFRU+FRU_start);
      for (i = 0; i < Nstates_FRU; i++) {
	      FRU_states_local[iFRU][i] = FRU_states[FRU_start+iFRU][i];
      }
      for (icleft = 0; icleft < Nclefts_FRU; icleft++) {
        for (i = 0; i < NRyRs_per_cleft; i++) {
          RyR_state_local[iFRU][icleft][i] = RyR_state[FRU_start+iFRU][icleft][i];
        }
        for (i = 0; i < NLType_per_cleft; i++) {
        LType_state_local[iFRU][icleft][i][index_LCC_states] = LType_state[FRU_start+iFRU][icleft][i][index_LCC_states];
        LType_state_local[iFRU][icleft][i][index_LCC_Vinact] = LType_state[FRU_start+iFRU][icleft][i][index_LCC_Vinact];
        LType_state_local[iFRU][icleft][i][index_LCC_phosph] = LType_state[FRU_start+iFRU][icleft][i][index_LCC_phosph];
        LType_state_local[iFRU][icleft][i][index_LCC_mode2] = LType_state[FRU_start+iFRU][icleft][i][index_LCC_mode2];
        }
      Ito2_state_local[iFRU][icleft] = Ito2_state[FRU_start+iFRU][icleft];
      }
      mti_local[iFRU] = mti[FRU_start+iFRU];
      for (i = 0; i < mtN; i++) {
	      mt_local[iFRU][i] = mt[FRU_start+iFRU][i];
      }
    }
#else
    memcpy(&FRU_states_local[0][0], &FRU_states[FRU_start][0], sizeof(double) * NFRU_local * Nstates_FRU);
    memcpy(&RyR_state_local[0][0][0], &RyR_state[FRU_start][0][0], sizeof(int) * NFRU_local * Nclefts_FRU * NRyRs_per_cleft);
    memcpy(&LType_state_local[0][0][0][0], &LType_state[FRU_start][0][0][0], sizeof(int) * NFRU_local * Nclefts_FRU * NLType_per_cleft * Nindepstates_LType);
    memcpy(&Ito2_state_local[0][0], &Ito2_state[FRU_start][0], sizeof(int) * NFRU_local * Nclefts_FRU);
    memcpy(&mti_local[0], &mti[FRU_start], sizeof(int) * NFRU_local);
    memcpy(&mt_local[0][0], &mt[FRU_start][0], sizeof(unsigned long) * NFRU_local * (mtN+1));
#endif

#if SIMPLEDEBUG
    // assign nonsense to global variable, since they are not be used after this point
    for(iFRU=0;iFRU<NFRU_local;iFRU++) {
      //printf("iFRU %d assigned to master\n",iFRU+FRU_start);
      // This is for testing purposes
      for (i = 0; i < Nstates_FRU; i++) {
	FRU_states[iFRU][i] = -1;
      }
      for (icleft = 0; icleft < Nclefts_FRU; icleft++) {
	for (i = 0; i < NRyRs_per_cleft; i++) {
	  RyR_state[iFRU][icleft][i] = -2;
	}
	for (i = 0; i < NLType_per_cleft; i++) {
	LType_state[iFRU][icleft][i][index_LCC_states] = -3;
	LType_state[iFRU][icleft][i][index_LCC_Vinact] = -4;
  if (i==0){
	LType_state[iFRU][icleft][i][index_LCC_phosph] = 1;
  }
  else{
  LType_state[iFRU][icleft][i][index_LCC_phosph] = 0;
  }
  LType_state[iFRU][icleft][i][index_LCC_mode2] = 0;
  }
	Ito2_state[iFRU][icleft] = -5;
      }
      mti[iFRU] = -6;
      for (i = 0; i < mtN; i++) {
	mt[iFRU][i] = -7;
      }
    }
#endif
}

#if USE_MPI
  // wait for an answer from other processes
  // to make sure that all processes have received the data
  if (procs>1) {
    tag=1;
    for(p=1;p<procs;p++) {
      MPI_Recv(&ok,1,MPI_INT,p,tag,MPI_COMM_WORLD,&status);
    }
    printf("Processors data received!\n");
  }
#endif
}

/* 
   void distrib_simFRU

   Have slave processes perform computations ie distributed simFRU

*/
void distrib_simFRU(double st_time,double end_time,
		    double FRUdep_states0[Nstates_FRUdep],
		    double FRUdep_statesf[Nstates_FRUdep],
		    double *Jxfer, 
		    double *Jtr, 
		    double *ICa, 
		    double *Ito2)
{
  int cont;
  int i;
  double num_stat[7],total_num[7];
  double input[2+2*Nstates_FRUdep];
  double Cai,CaNSR,V,Jtr_local,Jxfer_local,sum_CaSS_local,sum_CaJSR_local;
  double ICa_numerator,ICa_local,Ito2_local,NIto2_Open;
  double VF_over_RT, VFsq_over_RT, exp_2VFRT,exp_VFRT;
	
  cont=2;
  input[0]=st_time;
  input[1]=end_time;
  for(i=0;i<Nstates_FRUdep;i++) {
    input[2+i]=FRUdep_states0[i];
    input[2+Nstates_FRUdep+i]=FRUdep_statesf[i];
  }

  // Define a new type to make things faster

#if USE_MPI
  // Send command to compute and required data to slave processes
  MPI_Bcast(&cont,1,MPI_INT,0,MPI_COMM_WORLD);
  MPI_Bcast(input,2+2*Nstates_FRUdep,MPI_DOUBLE, 0, MPI_COMM_WORLD);
#endif

  V = FRUdep_statesf[index_frudep_V];
  Cai = FRUdep_statesf[index_frudep_Cai];
  CaNSR = FRUdep_statesf[index_frudep_CaNSR];
  VF_over_RT=V/RT_over_F;
  VFsq_over_RT=(1000.0*Faraday)*VF_over_RT;
  exp_VFRT = exp(VF_over_RT);
  exp_2VFRT = exp_VFRT*exp_VFRT;

  // Compute FRUs assigned to master process
  if (NFRU_local>0) {
    for(i=0;i<NFRU_local;i++) {
      simfru_local(st_time,end_time,
		   FRUdep_states0,
		   FRUdep_statesf,
		   &LType_state_local[i][0][0][0],
		   &RyR_state_local[i][0][0],
		   &Ito2_state_local[i][0],
		   &FRU_states_local[i][0],
		   &mti_local[i],
		   &mt_local[i][0]);
    }
    calc_fru_flux_local(NFRU_local,LType_state_local,Ito2_state_local,
			FRU_states_local,num_stat);
  } else {
    for(i=0;i<4;i++)
      num_stat[i]=0;
  }

#if USE_MPI  
  // Collect answers from slave processes
  for(i=0;i<6;i++)
    total_num[i]=0;

  MPI_Reduce(num_stat,total_num,5,MPI_DOUBLE,MPI_SUM,0,MPI_COMM_WORLD);

  sum_CaSS_local=total_num[0];
  sum_CaJSR_local=total_num[1];
  NIto2_Open=total_num[4];
#else
  sum_CaSS_local=num_stat[0];
  sum_CaJSR_local=num_stat[1];
  total_num[2]=num_stat[2];
  total_num[3]=num_stat[3];
  NIto2_Open=num_stat[4];
#endif

  // Compute actual currents
  if (fabs(V)<1.e-6) { // First order Taylor expansion
    ICa_numerator=total_num[2]-total_num[3]*Cao*0.341; 
    ICa_local = PCa*2.0*1000.0*Faraday*ICa_numerator;
    ICa_local = ICa_local/Acap;		// divide by uF(Acap) to get current normalized to surface area
    Ito2_local = ((double)NIto2_Open)*PCl*1000.0*Faraday*(Clo-Cli);
    Ito2_local = Ito2_local/Acap;	// divide by uF(Acap) to get current normalized to surface area
  } else {
    ICa_numerator=total_num[2]*exp_2VFRT-total_num[3]*Cao*0.341; 
    ICa_local = PCa*4.0*VFsq_over_RT*ICa_numerator/(exp_2VFRT-1.0); 
    ICa_local = ICa_local/Acap;		// divide by uF(Acap) to get current normalized to surface area
    Ito2_local = ((double)NIto2_Open)*PCl*VFsq_over_RT*(Cli-Clo*exp_VFRT)/(1.0 - exp_VFRT);
    Ito2_local = Ito2_local/Acap;	// divide by uF(Acap) to get current normalized to surface area
  }

  Jtr_local = (((double)NFRU_sim)*CaNSR - sum_CaJSR_local)/tautr;
  Jxfer_local = (sum_CaSS_local - ((double)NFRU_sim*(double)Nclefts_FRU)*Cai)/tauxfer;

  *Jxfer=NFRU_scale*Jxfer_local;
  *Jtr=NFRU_scale*Jtr_local;
  *ICa=NFRU_scale*ICa_local;
  *Ito2=NFRU_scale*Ito2_local;
}

/* 
   void send_save_state(void)

   save current state

*/
void send_save_state(void)
{
  int msg=MSG_SAVE_STATE; // save FRU state

#if USE_MPI
  MPI_Bcast(&msg,1,MPI_INT,0,MPI_COMM_WORLD);
#endif
  parallel_save_state();
}

/* 
   void send_resume_state(void)

   resume saved state

*/
void send_resume_state(void)
{
  int msg=MSG_RESUME_STATE; // save FRU state

#if USE_MPI
  MPI_Bcast(&msg,1,MPI_INT,0,MPI_COMM_WORLD);
#endif
  parallel_resume_state();
}

/* 
   void parallel_get_FRUs(void)

  recollects FRUs from slave processes and saves them to global FRU_states

*/
void parallel_get_FRUs(double FRU_states[NFRU_sim_max][Nstates_FRU],
		       int LType_state[NFRU_sim_max][Nclefts_FRU][NLType_per_cleft][Nindepstates_LType],
		       int RyR_state[NFRU_sim_max][Nclefts_FRU][NRyRs_per_cleft],
		       int Ito2_state[NFRU_sim_max][Nclefts_FRU],
		       unsigned long mt[NFRU_sim_max][mtN+1],int mti[NFRU_sim_max])
{
  int NFRU_local_sent_total=0;
  int p,i,iFRU,icleft;

#if USE_MPI
  int source;
  int msg=MSG_RETURN_FRU;
  MPI_Request request[100];
  MPI_Status status[MAXPROCS];
  int NFRU[MAXPROCS];
  int tag;
  int reqno=0;
  int dest;

  source=0; // receive from master
  MPI_Bcast(&msg,1,MPI_INT,0,MPI_COMM_WORLD); // get a command

  // first receive number of FRUs
  for(i=1;i<procs;i++) {
    reqno++;
    MPI_Irecv(&NFRU[i],1,MPI_INT,i,i,MPI_COMM_WORLD,&request[i-1]);
  }

  MPI_Waitall(reqno,request,status);

  NFRU_local_sent_total=0;
  for(i=1;i<procs;i++) {
    NFRU_local_sent_total+=NFRU[i];
    //printf("%d: NFRU[%d]=%d\n",i,i,NFRU[i]);
  }

  // then receive individual FRUs
  iFRU=0;
  for(p=1;p<procs;p++) {
    for(i=0;i<NFRU[p];i++) {
      reqno=0;
      dest=0;
      source=p;
      tag=p*1000+i;
      MPI_Irecv(&LType_state[iFRU][0][0][0],Nclefts_FRU*NLType_per_cleft*Nindepstates_LType,MPI_INT,source,tag,MPI_COMM_WORLD,&request[reqno]);
      reqno++;
      tag++;
      MPI_Irecv(&RyR_state[iFRU][0][0],Nclefts_FRU*NRyRs_per_cleft,MPI_INT,source,tag,MPI_COMM_WORLD,&request[reqno]);
      reqno++;
      tag++;
      MPI_Irecv(&Ito2_state[iFRU][0],Nclefts_FRU,MPI_INT,source,tag,MPI_COMM_WORLD,&request[reqno]);
      reqno++;
      tag++;
      MPI_Irecv(&FRU_states[iFRU][0],Nstates_FRU,MPI_DOUBLE,source,tag,MPI_COMM_WORLD,&request[reqno]);
      reqno++;
      tag++;
      MPI_Irecv(&mti[iFRU],1,MPI_INT,source,tag,MPI_COMM_WORLD,&request[reqno]);
      reqno++;
      tag++;
      MPI_Irecv(&mt[iFRU][0],mtN,MPI_UNSIGNED_LONG,source,tag,MPI_COMM_WORLD,&request[reqno]);
      reqno++;
      iFRU++;
      MPI_Waitall(reqno,request,status);
    }
  }
  //puts("Waitalls done");
#else
  NFRU_local_sent_total=0;
#endif

  //printf("%d FRUs received vs NFRU_local_sent_total=%d\n",iFRU,NFRU_local_sent_total);

  // assign extra FRUs to the master
  if (NFRU_sim>NFRU_local_sent_total) {
    int FRU_start;
    
    FRU_start=NFRU_local_sent_total;

    //printf("0: NFRU_local=%d\n",NFRU_local);

#if 1 // NOMEMCPY
    // copy states into a local copy also for the master
    for(iFRU=0;iFRU<NFRU_local;iFRU++) {
      for (icleft = 0; icleft < Nstates_FRU; icleft++) {
	FRU_states[FRU_start+iFRU][icleft] = FRU_states_local[iFRU][icleft];
      }
      for (icleft = 0; icleft < Nclefts_FRU; icleft++) {
	for (i = 0; i < NRyRs_per_cleft; i++) {
	  RyR_state[FRU_start+iFRU][icleft][i] = RyR_state_local[iFRU][icleft][i];
	}
	for (i = 0; i < NLType_per_cleft; i++) {
	LType_state[FRU_start+iFRU][icleft][i][index_LCC_states] = LType_state_local[iFRU][icleft][i][index_LCC_states];
	LType_state[FRU_start+iFRU][icleft][i][index_LCC_Vinact] = LType_state_local[iFRU][icleft][i][index_LCC_Vinact];
  LType_state[FRU_start+iFRU][icleft][i][index_LCC_phosph] = LType_state_local[iFRU][icleft][i][index_LCC_phosph];
  LType_state[FRU_start+iFRU][icleft][i][index_LCC_mode2] = LType_state_local[iFRU][icleft][i][index_LCC_mode2];
  }
	Ito2_state[FRU_start+iFRU][icleft] = Ito2_state_local[iFRU][icleft];
      }
      mti[FRU_start+iFRU] = mti_local[iFRU];
      for (i = 0; i < mtN; i++) {
	mt[FRU_start+iFRU][i] = mt_local[iFRU][i];
      }
    }
#else
    memcpy(&FRU_states[FRU_start][0], &FRU_states_local[0][0], sizeof(double) * NFRU_local * Nstates_FRU);
    memcpy(&RyR_state[FRU_start][0][0], &RyR_state_local[0][0][0], sizeof(int) * NFRU_local * Nclefts_FRU * NRyRs_per_cleft);
    memcpy(&LType_state[FRU_start][0][0][0], &LType_state_local[0][0][0][0], sizeof(int) * NFRU_local * Nclefts_FRU * 2);
    memcpy(&Ito2_state[FRU_start][0], &Ito2_state_local[0][0], sizeof(int) * NFRU_local * Nclefts_FRU);
    memcpy(&mti[FRU_start], &mti_local[0], sizeof(int) * NFRU_local);
    memcpy(&mt[FRU_start][0], &mt_local[0][0], sizeof(unsigned long) * NFRU_local * (mtN+1));
#endif
  }
}

/* 
   void initialize_mpi(int *argc,char **argv,int *my_rank,int *procs)

   initializes MPI community

*/
void initialize_mpi(int *argc,char **argv,int *rank,int *proces)
{
#if USE_MPI
  MPI_Init(argc,&argv);

  MPI_Comm_rank(MPI_COMM_WORLD,rank);
  MPI_Comm_size(MPI_COMM_WORLD,proces);
  
  printf("My rank is %d out of %d\n",*rank,*proces);
#endif
}

/* 
   void end_mpi

   shutdown MPI

*/
void end_mpi(void)
{
  int cont=1; // exit

#if USE_MPI
  MPI_Bcast(&cont,1,MPI_INTEGER,0,MPI_COMM_WORLD);
  MPI_Finalize();
#endif
}

