#include "StochModel.h"
#include <fstream>
#include <math.h>
#include <stdio.h>      /* printf, scanf, puts, NULL */
#include <stdlib.h>     /* srand, rand */
#include <time.h>       /* time */
#include <iostream>
#include <stdio.h>
#include <string.h>
#include <string>
#include <fstream>
#include <sstream>

int main(int argc, char **argv){
	printf("Beginning simulation...\n");

	StochModel s1 = StochModel();
	for (int LQTS1_index = 95; LQTS1_index < 100; ++LQTS1_index) {
		s1.Load_State_File("v2_2.StochData.txt", "v2_2.FRUsData.txt");
		s1.Read_LQTS1_p("general_params.txt", LQTS1_index);

		//Randomly set the random seed
		int iRand, iRand2;
		srand(time(NULL));
		iRand2 = rand() % 100000000 + 1;
		s1.Set_Seed((unsigned long)iRand2);
		
		std::filebuf fb1;

		double dt = 1;
		double t = 0;

		double t_final = 111000;//s1.Get_T_Final(); //60000;
		double g_gap = 0;//100; //780; //nS
		double g_ca = 0;

		double I_stim = s1.Get_I_Stim(); //0; //-10000;
		double shift_stim = 10;//10;//ERROR!!! changing in voltage-clamping test
		double duration_stim = 0.99; //0.99; //200; //0.99;
		double period_stim = s1.Get_Period(); //250;
		double t_end_stim = 112000; //2000;
		double save_interval = 100000.0;

		double t_stim_refractory = 120000;

		//To create the filename with random number
		char fn[80];
		if(LQTS1_index<10){
		strcpy(fn, "v2_2.set0.s000");	
		}
		else if(LQTS1_index<100){
			strcpy(fn, "v2_2.set0.s00");
		}
		else if(LQTS1_index<1000){
			strcpy(fn, "v2_2.set0.s0");
		}
		else{
			strcpy(fn, "v2_2.set0.s");
		}

		std::stringstream ss2;
		ss2 << LQTS1_index;
		std::string fnnum2(ss2.str());
		//std::string fnnum = std::to_string(iRand2);
		const char *fnnumchar2 = fnnum2.c_str();
		strcat(fn, fnnumchar2);
		strcat(fn, ".");

		std::stringstream ss;
		ss << iRand2;
		std::string fnnum(ss.str());
		//std::string fnnum = std::to_string(iRand2);
		const char *fnnumchar = fnnum.c_str();
		strcat(fn, fnnumchar);
		strcat(fn, ".txt");

		fb1.open(fn, std::ios::out);
		std::ostream os1(&fb1);
		//s1.Write_Info_Header(os1);//ERROR!!!
		s1.Write_Info(os1, t);

		double JCa1 = 0;
		int stepno = 0;

		printf("Beginning simulation...\n");
		while (t < t_final) {
			double v1 = s1.Get_V();
			double v2 = 0;

			double I_gap = g_gap * (v1 - v2);
			double I1 = I_gap;
			double I2 = -I_gap;


			double time_on_Is1 = floor(t / period_stim) * period_stim;
			double time_off_Is1 = time_on_Is1 + duration_stim;
			if (((t - shift_stim) >= time_on_Is1 && (t - shift_stim) <= time_off_Is1 && t < t_end_stim) ||
				(t - shift_stim >= t_stim_refractory && t - shift_stim <= t_stim_refractory + duration_stim)) {
				I1 += I_stim;
			}
			s1.Integrate_Iext_Ca(dt, I1, JCa1);

			t += dt;
			stepno++;

			s1.Initialize_Currents(I1, JCa1); //re-compute currents
			s1.Write_Info(os1, t);
		}

		fb1.close();

	}
	return 0;
}
