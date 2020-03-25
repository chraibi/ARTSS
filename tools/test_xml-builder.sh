#!/usr/bin/env bash
CLEAN=1
#create test cases
function create_testcases {
  if [ $ADV -eq 1 ];
  then
    ####################Advection####################
    NAMEVALUES[$INDEX]=Advection
    FPATHVALUES[$INDEX]=Advection
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --advection --tend 2.0 --dt 0.001 --advectiontype SemiLagrangian --solavail Yes  --xstart 0. --xend 2.0 --ystart 0. --yend 2.0 --zstart 0. --zend 1.0 --nx 40 --ny 40 --nz 1"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
    </boundaries>" > "${NAME}_${BFILEVAL}"
    echo "
    <initial_conditions usr_fct = \"GaussBubble\" >     <!-- Gaussian function  -->
      <u_lin> 0.5 </u_lin>              <!-- x-velocity in linear case  -->
      <v_lin> 0.5 </v_lin>              <!-- y-velocity in linear case  -->
      <w_lin> 0.25 </w_lin>             <!-- z-velocity in linear case  -->
      <xshift> 1.025 </xshift>          <!-- xshift of Gauss Bubble in domain  -->
      <yshift> 1.025 </yshift>          <!-- yshift of Gauss Bubble in domain  -->
      <zshift> 0.5 </zshift>            <!-- zshift of Gauss Bubble in domain  -->
      <l> 0.03125 </l>                  <!-- sigma in Gaussian -->
    </initial_conditions>" > "${NAME}_${IFILEVAL}"
    ((INDEX++))
  fi
  if [ $BUR -eq 1 ]
  then
    ####################Burgers####################
    NAMEVALUES[$INDEX]=Burgers
    FPATHVALUES[$INDEX]=Burgers
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --burgers --tend 1.0 --dt 0.01 --nu 0.1 --diffusiontype Jacobi --advectiontype SemiLagrangian --solavail Yes  --xstart -3.1415926536 --xend 3.1415926536 --ystart -3.1415926536 --yend 3.1415926536 --zstart -3.1415926536 --zend 3.1415926536 --nx 40 --ny 40 --nz 1"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"ExpSinusSum\" >     <!-- product of exponential and sinuses exp*sin*sin*sin -->
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))
  fi
  if [ $DIFF -eq 1 ]
  then
    ####################Diffusion####################
    NAMEVALUES[$INDEX]=Diffusion
    FPATHVALUES[$INDEX]=Diffusion
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --diffusion --tend 1.0 --dt 0.0125 --nu 0.001 --diffusiontype Jacobi --solavail Yes  --xstart 0. --xend 2.0 --ystart 0. --yend 2.0 --zstart 0. --zend 1.0 --nx 40 --ny 40 --nz 1"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"ExpSinusProd\" >     <!-- product of exponential and sinuses exp*sin*sin*sin -->
      <l> 2.5 </l>                              <!-- wavelength -->
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))
    ####################Diffusion Hat####################
    NAMEVALUES[$INDEX]=Diffusion_Hat
    FPATHVALUES[$INDEX]=Diffusion/Hat
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --diffusion --tend 1.0 --dt 0.02 --nu 0.05 --diffusiontype Jacobi --solavail No  --xstart 0. --xend 2. --ystart 0. --yend 2. --zstart 0. --zend 2. --nx 32 --ny 32 --nz 32"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,top,bottom,left,right\" type=\"dirichlet\" value=\"1.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Hat\" >     <!-- 2 in [0.5;1.0]^3, 1 elsewhere -->
      <x1> 0.5 </x1>
      <x2> 1.0 </x2>
      <y1> 0.5 </y1>
      <y2> 1.0 </y2>
      <z1> 0.5 </z1>
      <z2> 1.0 </z2>
      <val_in> 2.0 </val_in>
      <val_out> 1.0 </val_out>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))
  fi
  if [ $DIFFT -eq 1 ]
  then
    ####################DiffusionTurb####################
    NAMEVALUES[$INDEX]=DiffusionTurb
    FPATHVALUES[$INDEX]=DiffusionTurb
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --diffturb --tend 1.0 --dt 0.0125 --nu 0.001 --diffusiontype Jacobi --turbulencetype ConstSmagorinsky --cs 0.2 --solavail No  --xstart 0. --xend 2.0 --ystart 0. --yend 2.0 --zstart 0. --zend 1.0 --nx 40 --ny 40 --nz 1"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"ExpSinusProd\" >     <!-- product of exponential and sinuses exp*sin*sin*sin -->
      <l> 2.5 </l>                              <!-- wavelength -->
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))
  fi
  if [ $NS -eq 1 ]
  then

    ####################NavierStokes Beltrami####################
    NAMEVALUES[$INDEX]=NavierStokesBeltrami
    FPATHVALUES[$INDEX]=NavierStokes/Beltrami
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --ns --tend 0.05 --dt 0.000625 --nu 0.01 --beta 0. --advectiontype SemiLagrangian --diffusiontype Jacobi  --sourcetype ExplicitEuler --forcefct Zero --forcedir xyz --pressuretype VCycleMG --nlevel 4 --ncycle 2 --maxiter 100 --pressurediffusiontype Jacobi --solavail Yes  --xstart -1. --xend 1. --ystart -1. --yend 1. --zstart -1. --zend 1. --nx 32 --ny 32 --nz 32 --maxsolve 500"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.\" />
      <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"-1.52944\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Beltrami\" >
      <a> 0.7853981634 </a>
      <d> 1.5707963268 </d>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))
    ####################NavierStokes CavityFlow####################
    NAMEVALUES[$INDEX]=NavierStokesCavity
    FPATHVALUES[$INDEX]=NavierStokes/CavityFlow
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --ns --tend 0.5 --dt 0.001 --nu 0.1 --advectiontype SemiLagrangian --diffusiontype Jacobi  --sourcetype ExplicitEuler --forcefct Zero --forcedir xyz --pressuretype VCycleMG --nlevel 4 --ncycle 2 --maxiter 50 --pressurediffusiontype Jacobi --solavail No  --xstart 0. --xend 2. --ystart 0. --yend 2. --zstart 0. --zend 2. --nx 40 --ny 40 --nz 1"
    echo "
    <boundaries>
      <boundary field=\"u\" patch=\"top\" type=\"dirichlet\" value=\"1.0\" />
      <boundary field=\"u\" patch=\"front,back,left,right,bottom\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"v,w\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"top\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"front,back,left,right,bottom\" type=\"neumann\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Zero\" >
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))

    ####################NavierStokes ChannelFlow####################
    NAMEVALUES[$INDEX]=NavierStokesChannel
    FPATHVALUES[$INDEX]=NavierStokes/ChannelFlow
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --ns --tend 10. --dt 0.01 --nu 0.1 --advectiontype SemiLagrangian --diffusiontype Jacobi --pressuretype VCycleMG --nlevel 4 --ncycle 2 --maxiter 100 --pressurediffusiontype Jacobi --solavail No  --xstart 0. --xend 2. --ystart 0. --yend 2. --zstart 0. --zend 2. --nx 40 --ny 40 --nz 1 --nplots 50"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"left,right\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"u,v,w\" patch=\"front,back,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"left,right\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"front,back,top,bottom\" type=\"neumann\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Zero\" >
    </initial_conditions>" > ${NAME}_$IFILEVAL
    echo "
    <source type = \"ExplicitEuler\" force_fct=\"Uniform\" dir = \"x\"> <!--Direction of force (x,y,z or combinations xy,xz,yz, xyz)     -->
      <val_x> 1. </val_x>
      <val_y> 0. </val_y>
      <val_z> 0. </val_z>
    </source>" > ${NAME}_$SFILEVAL
    ((INDEX++))

    ####################NavierStokes McDermott####################
    NAMEVALUES[$INDEX]=NavierStokesMcDermott
    FPATHVALUES[$INDEX]=NavierStokes/McDermott
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --ns --tend 6.2831853072 --dt 0.01 --nu 0.1 --beta 0. --advectiontype SemiLagrangian --diffusiontype Jacobi  --sourcetype ExplicitEuler --forcefct Zero --forcedir xyz --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --solavail Yes  --xstart 0. --xend 6.2831853072 --ystart 0. --yend 6.2831853072 --zstart 0. --zend 6.2831853072 --nx 64 --ny 64 --nz 1"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"McDermott\" >
      <A> 2 </A>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))

    ####################NavierStokes Vortex####################
    NAMEVALUES[$INDEX]=NavierStokesVortex
    FPATHVALUES[$INDEX]=NavierStokes/Vortex
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --ns --tend 1.0 --dt 0.01 --nu 0. --advectiontype SemiLagrangian --diffusiontype Jacobi  --sourcetype ExplicitEuler --forcefct Zero --forcedir xyz --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --solavail Yes  --xstart -0.1556 --xend 0.1556 --ystart -0.1556 --yend 0.1556 --zstart -0.1556 --zend 0.1556 --nx 64 --ny 64 --nz 1"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Vortex\" >
      <u_lin> 0.1 </u_lin>
      <v_lin> 0 </v_lin>
      <w_lin> 0 </w_lin>
      <pa> 0. </pa>
      <rhoa> 1. </rhoa>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))

    ####################NavierStokes Vortex Adaption####################
    NAMEVALUES[$INDEX]=NavierStokesVortexAdaption
    FPATHVALUES[$INDEX]=NavierStokes/Vortex/DynamicBoundaries
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --ns --tend 40. --dt 0.01 --nu 0. --beta 0. --advectiontype SemiLagrangian --diffusiontype Jacobi  --sourcetype ExplicitEuler --forcefct Zero --forcedir xyz --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --solavail Yes  --xstart -0.5 --xendc 0.5 --xendp 4.5 --ystart -0.5 --yend 0.5 --zstart -0.5 --zend 0.5 --nx 256 --ny 256 --nz 1 --nplots 10"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"VortexY\" >
      <u_lin> 0.1 </u_lin>
      <v_lin> 0 </v_lin>
      <w_lin> 0 </w_lin>
      <pa> 0. </pa>
      <rhoa> 1. </rhoa>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    echo "
    <class name=\"Vortex\">
      <buffer> 6 </buffer>
      <threshold>0.001</threshold>
      <reduction enabled=\"Yes\" dir=\"x\"> </reduction>
    </class>" > ${NAME}_$AFILEVAL
    ((INDEX++))
  fi
  if [ $NSTC -eq 1 ]
  then
    ####################NavierStokesTempTurbCon HotPlume####################
    NAMEVALUES[$INDEX]=NavierStokesTempCon_HotPlume
    FPATHVALUES[$INDEX]=NavierStokesTempCon/Plume
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nstempcon --tend 60. --dt 0.05 --nu 3.1e-5 --beta 3.4e-3 --g -9.81 --kappa 4.2e-5 --advectiontype SemiLagrangian --diffusiontype Jacobi --turbulencetype ConstSmagorinsky --cs 0.2 --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --tempadvtype SemiLagrangian --tempdifftype Jacobi --prt 0.9 --gamma 0.01 --solavail No --xstart -2. --xend 2. --ystart -2. --yend 2. --zstart -2. --zend 2. --nx 64 --ny 64 --nz 1 --nplots 50"

    echo "
  	<boundaries>
  		<boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
  		<boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.0\" />
  		<boundary field=\"T\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.0\" />
  		<boundary field=\"rho\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.0\" />
  		<surface ID=\"0\" field=\"T\" patch=\"bottom\" type=\"dirichlet\" value=\"300.0\" />
  		<surface ID=\"0\" field=\"rho\" patch=\"bottom\" type=\"dirichlet\" value=\"0.3\" />
  	</boundaries>" > ${NAME}_$BFILEVAL

    echo "
	  <initial_conditions usr_fct = \"Zero\" >     <!-- Exp*Sin(x+y) function  -->
	  </initial_conditions>" > ${NAME}_$IFILEVAL

    echo "
		<surface ID=\"0\" sx1=\"-0.09375\" sx2=\"0.09375\" sy1=\"-2.03125\" sy2=\"-2.03125\" sz1=\"0.\" sz2=\"0.\"/>" > ${NAME}_$DSFILEVAL

    ((INDEX++))
  fi
  if [ $NSTe -eq 1 ]
  then
    ####################NavierStokesTemp Dissipation####################
    NAMEVALUES[$INDEX]=Dissipation
    FPATHVALUES[$INDEX]=Dissipation
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nstemp --tend 10. --dt 0.001 --nu 0. --beta 0. --kappa 0. --advectiontype SemiLagrangian --diffusiontype Jacobi --pressuretype VCycleMG --nlevel 4 --ncycle 2 --maxcycle 4 --maxsolve 5 --pressurediffusiontype Jacobi --forcefct Zero --forcedir xyz --tempadvtype SemiLagrangian --tempdifftype Jacobi --tempsourcefct Zero --solavail No  --xstart 0. --xend 1. --ystart 0. --yend 1. --zstart 0. --zend 1. --nx 64 --ny 64 --nz 1 --nplots 50"
    echo "
    <boundaries>
      <boundary field=\"w\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"u,v\" patch=\"left,right,top,bottom\" type=\"dirichlet\" value=\"2.0\" />
      <boundary field=\"u,v\" patch=\"front,back\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.0\" />
      <boundary field=\"T\" patch=\"left,top\" type=\"dirichlet\" value=\"373.14\" />
      <boundary field=\"T\" patch=\"right,bottom\" type=\"dirichlet\" value=\"273.14\" />
      <boundary field=\"T\" patch=\"front,back\" type=\"neumann\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Drift\" ><!-- Drift function  -->
      <u_lin> 2. </u_lin>                     <!-- x-velocity in linear case  -->
      <v_lin> 2. </v_lin>                     <!-- y-velocity in linear case  -->
      <w_lin> 0. </w_lin>                     <!-- z-velocity in linear case  -->
      <pa> 0. </pa>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    echo "
    <source type = \"ExplicitEuler\" temp_fct = \"Zero\" dissipation=\"No\">
    </source>" > ${NAME}_$TSFILEVAL
    ((INDEX++))

    ####################NavierStokesTemp MMS####################
    NAMEVALUES[$INDEX]=NavierStokesBuoyancyMMS
    FPATHVALUES[$INDEX]=NavierStokesTemp/MMS
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nstemp --tend 1.0 --dt 0.005 --nu 0.05 --beta 1. --g -9.81 --kappa 0.05 --advectiontype SemiLagrangian --diffusiontype Jacobi --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --tempadvtype SemiLagrangian --tempdifftype Jacobi --solavail Yes  --xstart -2. --xend 2. --ystart -2. --yend 2. --zstart -2. --zend 2. --nx 64 --ny 64 --nz 1 --forcefct Buoyancy --forcedir y --tempsourcefct BuoyancyST_MMS"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"T\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"BuoyancyMMS\" >
      <rhoa> 1. </rhoa>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    echo "
    <source type = \"ExplicitEuler\" temp_fct = \"BuoyancyST_MMS\" dissipation=\"No\">
    </source>" > ${NAME}_$TSFILEVAL
    ((INDEX++))
  fi
  if [ $NSTT -eq 1 ]
  then
    ####################NavierStokesTempTurb Adaption####################
    NAMEVALUES[$INDEX]=NavierStokesTempTurbAdaption
    FPATHVALUES[$INDEX]=NavierStokesTempTurb/DynamicBoundaries
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nstempturb --tend 35. --dt 0.1 --nu 2.44139e-05 --beta 3.28e-3 --g -9.81 --kappa 3.31e-5 --advectiontype SemiLagrangian --diffusiontype Jacobi --turbulencetype ConstSmagorinsky --cs 0.2 --pressuretype VCycleMG --nlevel 6 --ncycle 2 --pressurediffusiontype Jacobi --tempadvtype SemiLagrangian --tempdifftype Jacobi --prt 0.5 --solavail No --xstartp 0. --xstartc 26. --xendp 128. --xendc 34. --ystart -3. --yend 3. --zstart -4. --zend 4. --nx 64 --ny 16 --nz 32 --dataextraction --adaptionbefore 2.7 --adaptiontime"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"u,v,w\" patch=\"left,right\" type=\"neumann\" value=\"0.0\" />        
      <boundary field=\"p\" patch=\"front,back,top,bottom\" type=\"neumann\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"left,right\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"T\" patch=\"front,back,top,left,right\" type=\"neumann\" value=\"0.0\" />
      <boundary field=\"T\" patch=\"bottom\" type=\"neumann\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL

    echo "
    <initial_conditions usr_fct = \"LayersT\" dir=\"y\">     <!-- Layers  -->
      <n_layers> 5 </n_layers>
      <border_1> -1.8 </border_1> <!-- at cell face -->
      <border_2> -0.6 </border_2> <!-- at cell face -->
      <border_3>  0.6 </border_3> <!-- at cell face -->
      <border_4>  1.8 </border_4> <!-- at cell face -->
      <value_1> 303.64 </value_1>
      <value_2> 304.04 </value_2>
      <value_3> 305.24 </value_3>
      <value_4> 308.84 </value_4>
      <value_5> 310.54 </value_5>
    </initial_conditions>" > ${NAME}_$IFILEVAL

    echo "
      <class name=\"Layers\">
        <buffer> 14 </buffer>
        <check_value> 335 </check_value>
        <timestep> 1 </timestep>
        <expansion_size> 1 </expansion_size>
      </class>" > ${NAME}_$AFILEVAL
    echo "
    <source type = \"ExplicitEuler\" temp_fct = \"GaussST\" ramp_fct = \"RampTanh\" dissipation = \"No\">
      <HRR> 25000. </HRR>             <!-- Total heat release rate (in kW) -->
      <cp> 1.023415823 </cp>  <!-- specific heat capacity (in kJ/kgK)-->
      <x0> 30.  </x0>
      <y0> -3. </y0>
      <z0> 0. </z0>
      <sigmax> 1.0 </sigmax>
      <sigmay> 1.5 </sigmay>
      <sigmaz> 1.0 </sigmaz>
      <tau> 5. </tau>
    </source>" > ${NAME}_$TSFILEVAL
    ((INDEX++))
    ####################NavierStokesTempTurb Tunnel####################
    NAMEVALUES[$INDEX]=NavierStokesTempTurb_Tunnel_100s
    FPATHVALUES[$INDEX]=NavierStokesTempTurb/DynamicBoundaries
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nstempturb --tend 100. --dt 0.01 --nu 2.44139e-05 --beta 3.28e-3 --g -9.81 --kappa 3.31e-5 --advectiontype SemiLagrangian --diffusiontype Jacobi --turbulencetype ConstSmagorinsky --cs 0.2 --pressuretype VCycleMG --nlevel 6 --ncycle 2 --pressurediffusiontype Jacobi --tempadvtype SemiLagrangian --tempdifftype Jacobi --prt 0.5 --solavail No --xstart 0. --xend 100. --ystart -3. --yend 3. --zstart -4. --zend 4. --nx 256 --ny 16 --nz 32 --nplots 100"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"u,v,w\" patch=\"left,right\" type=\"neumann\" value=\"0.0\" />        
      <boundary field=\"p\" patch=\"front,back,top,bottom\" type=\"neumann\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"left,right\" type=\"dirichlet\" value=\"0.0\" />
      <boundary field=\"T\" patch=\"front,back,top,left,right\" type=\"neumann\" value=\"0.0\" />
      <boundary field=\"T\" patch=\"bottom\" type=\"neumann\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL

    echo "
    <initial_conditions usr_fct = \"LayersT\" dir=\"y\">     <!-- Layers  -->
      <n_layers> 5 </n_layers>
      <border_1> -1.8 </border_1> <!-- at cell face -->
      <border_2> -0.6 </border_2> <!-- at cell face -->
      <border_3>  0.6 </border_3> <!-- at cell face -->
      <border_4>  1.8 </border_4> <!-- at cell face -->
      <value_1> 303.64 </value_1>
      <value_2> 304.04 </value_2>
      <value_3> 305.24 </value_3>
      <value_4> 308.84 </value_4>
      <value_5> 310.54 </value_5>
    </initial_conditions>" > ${NAME}_$IFILEVAL

    echo "
    <source type = \"ExplicitEuler\" temp_fct = \"GaussST\" ramp_fct = \"RampTanh\" dissipation = \"No\">
      <HRR> 25000. </HRR>             <!-- Total heat release rate (in kW) -->
      <cp> 1.023415823 </cp>  <!-- specific heat capacity (in kJ/kgK)-->
      <x0> 30.  </x0>
      <y0> -3. </y0>
      <z0> 0. </z0>
      <sigmax> 1.0 </sigmax>
      <sigmay> 1.5 </sigmay>
      <sigmaz> 1.0 </sigmaz>
      <tau> 5. </tau>
    </source>" > ${NAME}_$TSFILEVAL
    ((INDEX++))

    ####################NavierStokesTempTurb MMS####################
    NAMEVALUES[$INDEX]=NavierStokesTempTurbBuoyancyMMS
    FPATHVALUES[$INDEX]=NavierStokesTempTurb/MMS
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nstempturb --tend 1.0 --dt 0.005 --nu 0.05 --beta 1. --g -9.81 --kappa 0.05 --advectiontype SemiLagrangian --diffusiontype Jacobi --turbulencetype ConstSmagorinsky --cs 0.2 --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --tempadvtype SemiLagrangian --tempdifftype Jacobi --prt 0.9 --solavail No  --xstart -2. --xend 2. --ystart -2. --yend 2. --zstart -2. --zend 2. --nx 64 --ny 64 --nz 1 --nplots 10"
    echo "
    <boundaries>
      <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
      <boundary field=\"T\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"BuoyancyMMS\" >
      <rhoa> 1. </rhoa>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    echo "
    <source type = \"ExplicitEuler\" force_fct=\"Buoyancy\" dir = \"y\"> <!--Direction of force (x,y,z or combinations xy,xz,yz, xyz) -->
    </source>" > ${NAME}_$SFILEVAL
    echo "
    <source type = \"ExplicitEuler\" temp_fct = \"BuoyancyST_MMS\" dissipation=\"No\">
    </source>" > ${NAME}_$TSFILEVAL
    ((INDEX++))
  fi
  if [ $NSTTC -eq 1 ]
  then
    ####################NavierStokesTempTurbCon HotPlume####################
    NAMEVALUES[$INDEX]=NavierStokesTempTurbCon_HotPlume
    FPATHVALUES[$INDEX]=NavierStokesTempTurbCon/Plume
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nstempturbcon --tend 60. --dt 0.05 --nu 3.1e-5 --beta 3.4e-3 --g -9.81 --kappa 4.2e-5 --advectiontype SemiLagrangian --diffusiontype Jacobi --turbulencetype ConstSmagorinsky --cs 0.2 --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --tempadvtype SemiLagrangian --tempdifftype Jacobi --prt 0.9 --gamma 0.01 --solavail No --xstart -2. --xend 2. --ystart -2. --yend 2. --zstart -2. --zend 2. --nx 64 --ny 64 --nz 3 --nplots 50"

    echo "
  	<boundaries>
  		<boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
  		<boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.0\" />
  		<boundary field=\"T\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.0\" />
  		<boundary field=\"rho\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.0\" />
  		<surface ID=\"0\" field=\"T\" patch=\"bottom\" type=\"dirichlet\" value=\"573.14\" />
  		<surface ID=\"0\" field=\"rho\" patch=\"bottom\" type=\"dirichlet\" value=\"333\" />
  	</boundaries>" > ${NAME}_$BFILEVAL

    echo "
	  <initial_conditions usr_fct = \"Zero\" >     <!-- Exp*Sin(x+y) function  -->
	  </initial_conditions>" > ${NAME}_$IFILEVAL

    echo "
		<surface ID=\"0\" sx1=\"-0.09375\" sx2=\"0.09375\" sy1=\"-2.03125\" sy2=\"-2.03125\" sz1=\"0.\" sz2=\"0.\"/>" > ${NAME}_$DSFILEVAL

    ((INDEX++))
  fi
  if [ $NSTu -eq 1 ]
  then

    ####################NavierStokesTurb Beltrami####################
    NAMEVALUES[$INDEX]=NavierStokesTurbBeltrami
    FPATHVALUES[$INDEX]=NavierStokesTurb/Beltrami
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nstu --tend 0.05 --dt 0.000625 --nu 0.01 --beta 0. --advectiontype SemiLagrangian --diffusiontype Jacobi  --sourcetype ExplicitEuler --forcefct Zero --forcedir xyz --pressuretype VCycleMG --nlevel 4 --ncycle 2 --maxiter 100 --pressurediffusiontype Jacobi --solavail Yes  --xstart -1. --xend 1. --ystart -1. --yend 1. --zstart -1. --zend 1. --nx 32 --ny 32 --nz 32 --maxsolve 500 --cs 0.2"
    echo "
    <boundaries>
    <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.\" />
    <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"-1.52944\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Beltrami\" >
    <a> 0.7853981634 </a>
    <d> 1.5707963268 </d>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))
    ####################NavierStokesTurb McDermott####################
    NAMEVALUES[$INDEX]=NavierStokesTurbMcDermott
    FPATHVALUES[$INDEX]=NavierStokesTurb/McDermott
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nsturb --tend 6.2831853072 --dt 0.01 --nu 0.1 --advectiontype SemiLagrangian --diffusiontype Jacobi --turbulencetype ConstSmagorinsky --cs 0.2 --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --solavail No  --xstart 0. --xend 6.2831853072 --ystart 0. --yend 6.2831853072 --zstart 0. --zend 6.2831853072 --nx 64 --ny 64 --nz 1"
    echo "
    <boundaries>
    <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"McDermott\" >
    <A> 2 </A>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    echo "
    <source type = \"ExplicitEuler\" force_fct=\"Zero\" dir = \"xyz\"> <!--Direction of force (x,y,z or combinations xy,xz,yz, xyz) -->
    </source>" > ${NAME}_$SFILEVAL
    ((INDEX++))

    ####################NavierStokesTurb Vortex####################
    NAMEVALUES[$INDEX]=NavierStokesTurbVortex
    FPATHVALUES[$INDEX]=NavierStokesTurb/Vortex
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nsturb --tend 1.0 --dt 0.01 --nu 0. --advectiontype SemiLagrangian --diffusiontype Jacobi --turbulencetype ConstSmagorinsky --cs 0.2 --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --solavail No  --xstart -0.1556 --xend 0.1556 --ystart -0.1556 --yend 0.1556 --zstart -0.1556 --zend 0.1556 --nx 64 --ny 64 --nz 1"
    echo "
    <boundaries>
    <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"periodic\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Vortex\" >
    <u_lin> 0.1 </u_lin>
    <v_lin> 0 </v_lin>
    <w_lin> 0 </w_lin>
    <pa> 0. </pa>
    <rhoa> 1. </rhoa>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    echo "
    <source type = \"ExplicitEuler\" force_fct=\"Zero\" dir = \"xyz\"> <!--Direction of force (x,y,z or combinations xy,xz,yz, xyz) -->
    </source>" > ${NAME}_$SFILEVAL
    ((INDEX++))

    ####################NavierStokesTurb Flow Around Cube ####################
    NAMEVALUES[$INDEX]=NavierStokesTurb_FlowAroundCube_BoundaryHandling

    FPATHVALUES[$INDEX]=NavierStokesTurb/FlowAroundCube
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --nsturb --tend 10. --dt 0.01 --nu 0.00001 --advectiontype SemiLagrangian --diffusiontype Jacobi  --sourcetype ExplicitEuler --forcefct Zero --forcedir xyz --pressuretype VCycleMG --nlevel 5 --ncycle 2 --maxcycle 4 --maxiter 100 --pressurediffusiontype Jacobi --solavail No  --xstart -3. --xend 7. --ystart 0. --yend 2. --zstart -3.5 --zend 3.5 --nx 256 --ny 128 --nz 256 --nplots 50"
    echo "
     <obstacle>
       <geometry ox1=\"0.0273\" ox2=\"0.964\" oy1=\"0.0078\" oy2=\"0.992\" oz1=\"-0.492\" oz2=\"0.4785\"/> 
       <boundary field=\"u,v,w\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
       <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"neumann\" value=\"0.0\" />
    </obstacle>" > ${NAME}_$DOFILEVAL
    echo "
    <boundaries>
    <boundary field=\"u\" patch=\"left\" type=\"dirichlet\" value=\"0.4\" />
    <boundary field=\"u\" patch=\"right\" type=\"dirichlet\" value=\"0.4\" />
    <boundary field=\"v\" patch=\"left,right\" type=\"dirichlet\" value=\"0.0\" />
    <boundary field=\"w\" patch=\"left,right\" type=\"dirichlet\" value=\"0.0\" />
    <boundary field=\"u,v,w\" patch=\"front,back,top,bottom\" type=\"neumann\" value=\"0.0\" />
    <boundary field=\"p\" patch=\"left,right\" type=\"neumann\" value=\"0.0\" />
    <boundary field=\"p\" patch=\"front,back,top,bottom\" type=\"neumann\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"Drift\" >
    <u_lin> 0.4 </u_lin>                        <!-- background velocity -->
    <v_lin> 0.0 </v_lin>                        <!-- background velocity -->
    <w_lin> 0.0 </w_lin>                        <!-- background velocity -->
    <pa> 0. </pa>                               <!-- ambient pressure -->
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))

  fi
  if [ $PRE -eq 1 ]
  then
    ####################Pressure####################
    NAMEVALUES[$INDEX]=Pressure
    FPATHVALUES[$INDEX]=Pressure
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --pressure --tend 0.1 --dt 0.1 --pressuretype VCycleMG --nlevel 5 --ncycle 2 --pressurediffusiontype Jacobi --solavail Yes  --xstart 0. --xend 2. --ystart 0. --yend 2. --zstart 0. --zend 2. --nx 64 --ny 64 --nz 64"
    echo "
    <boundaries>
    <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"SinSinSin\" >
    <l> 2. </l>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    ((INDEX++))
    
    ####################Pressure####################
    NAMEVALUES[$INDEX]=BoundaryHandling_Pressure
    FPATHVALUES[$INDEX]=Pressure/BoundaryHandling
    NAME=${NAMEVALUES[$INDEX]}
    BUILDER[$INDEX]="./xml-builder.sh --pressure --tend 0.1 --dt 0.1 --pressuretype VCycleMG --nlevel 4 --ncycle 2 --pressurediffusiontype Jacobi --solavail No  --xstart 0. --xendc 2. --xendp 12. --ystart 0. --yendc 2. --yendp 3. --zstart 0. --zend 2. --nx 64 --ny 64 --nz 64 --maxsolve 200"
    echo "
    <boundaries>
    <boundary field=\"p\" patch=\"front,back,left,right,top,bottom\" type=\"dirichlet\" value=\"0.0\" />
		<obstacle ID=\"0\" field=\"p\" patch=\"front,back,left,right\" type=\"neumann\" value=\"0.0\" />
		<obstacle ID=\"0\" field=\"p\" patch=\"top,bottom\" type=\"neumann\" value=\"1.0\" />
		<obstacle ID=\"1\" field=\"p\" patch=\"front,back,top,bottom,left,right\" type=\"neumann\" value=\"0.0\" />
		<surface ID=\"0\" field=\"p\" patch=\"bottom\" type=\"dirichlet\" value=\"1.0\" />
		<surface ID=\"1\" field=\"p\" patch=\"right\" type=\"dirichlet\" value=\"1.0\" />
    </boundaries>" > ${NAME}_$BFILEVAL
    echo "
    <initial_conditions usr_fct = \"SinSinSin\" >
    <l> 2. </l>
    </initial_conditions>" > ${NAME}_$IFILEVAL
    echo "
		<obstacle ID=\"0\" ox1=\"0.640625\" ox2=\"1.640625\" oy1=\"0.640625\" oy2=\"1.640625\" oz1=\"0.640625\" oz2=\"1.640625\"/> 			<!-- obstacle domain (needs to correspond to grid step size) -->
		<obstacle ID=\"1\" ox1=\"7.640625\" ox2=\"10.640625\" oy1=\"0.640625\" oy2=\"0.640625\" oz1=\"0.640625\" oz2=\"0.640625\"/>
		<surface ID=\"0\" sx1=\"0.515625\" sx2=\"1.525625\" sy1=\"-0.015625\" sy2=\"-0.015625\" sz1=\"0.515625\" sz2=\"1.525625\"/> 			<!-- surface domain (needs to correspond to grid step size) -->
		<surface ID=\"1\" sx1=\"2.015625\" sx2=\"2.015625\" sy1=\"0.515625\" sy2=\"1.515625\" sz1=\"0.515625\" sz2=\"1.525625\"/>" > ${NAME}_$DOFILEVAL
    ((INDEX++))
  fi
}

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0;m'

#help text
DESCRIPTION="Script to test xml-builder.sh. It generates an already constructed XML File from the 'Test' directory and compares the generated with the existing.\n"
OPTIONSA="
Basic options:
${YELLOW} -g${NC} \t generate defined test cases. If not checked, the generated test files will be removed
${YELLOW} -t${NC} \t test function - compare generated and existing xml
${YELLOW} -v${NC} \t if the generated xml does not equal the existing xml, show difference(s)

Advanced Options:"
OPTIONSB="

${YELLOW}--adv${NC}
${YELLOW}--advection${NC} \t test defined Advection test cases
${YELLOW}--bur${NC}
${YELLOW}--burgers${NC} \t test defined Burgers test cases
${YELLOW}--diff${NC}
${YELLOW}--diffusion${NC} \t test defined Diffusion test cases
${YELLOW}--difft${NC}
${YELLOW}--diffturb${NC} \t test defined Diffusion Turbulence test cases
${YELLOW}--generate${NC} \t generate defined test cases. If not checked, the generated test files will be removed
${YELLOW}--ns${NC}
${YELLOW}--navierstokes${NC} \t test defined Navier Stokes test cases
${YELLOW}--nste${NC}
${YELLOW}--nstemp${NC} \t test defined Navier Stokes Temperature test cases
${YELLOW}--nstc${NC}
${YELLOW}--nstempcon${NC} \t test defined Navier Stokes Temperature Concentration test cases
${YELLOW}--nstt${NC}
${YELLOW}--nstempturb${NC} \t test defined Navier Stokes Temperature Turbulence test cases
${YELLOW}--nsttc${NC}
${YELLOW}--nstempturbcon${NC} \t test defined Navier Stokes Temperature Turbulence Concentraion test cases
${YELLOW}--nstu${NC}
${YELLOW}--nsturb${NC} \t test defined Navier Stokes Turbulence test cases
${YELLOW}--overwrite${NC} \t if the file name for the generating xml file is already taken, overwrite it (pattern: 'Test_[NAME].xml'
${YELLOW}--pre${NC}
${YELLOW}--pressure${NC} \t test defined Pressure test cases
${YELLOW}--test${NC} \t test function - compare generated and existing xml file
${YELLOW}--verbose${NC} \t if the generated xml does not equal the existing file, show difference(s)
"
EXTRA="\n
special combination:
if ${YELLOW}--generate${NC} and ${YELLOW}--verbose${NC} are selected, temporary files like the file containing the boundary conditions will not be removed
  "
  EXAMPLE="
  Example: './test_builder.sh -g --ns' generate with xml-builder all (in test_builder) implemented navier stokes test cases
  "
  #parse help text
  COUNTER=0
  TMP=0
  while IFS= read -r LINE
  do
    if [ ! -z "$LINE" ]
    then
      tmpa=$(echo -e "$LINE" | cut -f1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
      options[$COUNTER]="$tmpa"
      tmpb="$(echo -e "$LINE" | cut -f2 )"
      if [[ "$tmpa" != "$tmpb" ]]
      then
        text[$COUNTER]="$tmpb"
      fi
      ((COUNTER++))
    fi
  done < <(printf '%s\n' "$OPTIONSB")

  for ((i=0;i<$COUNTER;i++))
  do
    OPTIONS=$OPTIONS$'\n'$(printf "%-37s%s\n" ${options[$i]} "${text[$i]}")
  done
  HELP="${DESCRIPTION}${OPTIONSA}${OPTIONS}${EXTRA}${EXAMPLE}"

  #different files
  BFILEVAL=bfile.txt #boundary condition
  IFILEVAL=ifile.txt #initial condition
  SFILEVAL=sfile.txt #source
  TSFILEVAL=tsfile.txt #temperature source
  DSFILEVAL=dsfile.txt #domain surfaces
  DOFILEVAL=dofile.txt #domain obstacles
  AFILEVAL=afile.txt #adaption parameter

  INDEX=0

  #different test cases
  ADV=0 #advection
  BUR=0 #burgers
  DIFF=0 #diffusion
  DIFFT=0 #diffusion turb
  NS=0 #navier stokes
  NSTu=0 #navier stokes turb
  NSTe=0 #navier stokes temp
  NSTT=0 #navier stokes temp turb
  NSTC=0 #navier stokes temp con
  NSTTC=0 #navier stokes temp turb con
  PRE=0 #pressure

  GENERATE=0 #generate test case
  TESTE=0 #compare generated and example xml
  CLEAR=0
  VERBOSE=0 #show difference

  while [[ $# -gt 0 ]]
  do
    key="$1"
    case "$key" in
      --adv|--advection)
        ADV=1
        shift
        ;;
      --bur|--burgers)
        BUR=1
        shift
        ;;
      --clean)
        CLEAN=0
        shift
        ;;
      --diff|--diffusion)
        DIFF=1
        shift
        ;;
      --difft|--diffturb)
        DIFFT=1
        shift
        ;;
      -g|--generate)
        GENERATE=1
        shift
        ;;
      -h|--help)
        echo -e "$HELP"
        exit
        ;;
      --ns|--navierstokes)
        NS=1
        shift
        ;;
      --nste|--nstemp)
        NSTe=1
        shift
        ;;
      --nstc|--nstempcon)
        NSTC=1
        shift
        ;;
      --nstt|--nstempturb)
        NSTT=1
        shift
        ;;
      --nsttc|--nstempturbcon)
        NSTTC=1
        shift
        ;;
      --nstu|--nsturb)
        NSTu=1
        shift
        ;;
      --overwrite)
        CLEAR=1
        shift
        ;;
      --pre|--pressure)
        PRE=1
        shift
        ;;
      -t|--test)
        TESTE=1
        shift
        ;;
      -v|--verbose)
        VERBOSE=1
        shift
        ;;
      *)
        POSITIONAL+=("$1")
        echo "unknown option: $1"
        shift
        ;;
    esac
  done

  SUMME=$((ADV+BUR+DIFF+DIFFT+NS+NSTe+NSTC+NSTT+NSTTC+NSTu+PRE))
  if [ $SUMME -eq 0 ]
  then
    ADV=1 #advection
    BUR=1 #burgers
    DIFF=1 #diffusion
    DIFFT=1 #diffusion turb
    NS=1 #navier stokes
    NSTu=1 #navier stokes turb
    NSTe=1 #navier stokes temp
    NSTT=1 #navier stokes temp turb
    NSTC=1 #navier stokes temp con
    NSTTC=1 #navier stokes temp turb con
    PRE=1 #pressure
  fi
  create_testcases

  FAIL=0
  for ((i=0; i<${#NAMEVALUES[@]}; i++))
  do
    NAME=${NAMEVALUES[$i]}
    FPATH="../tests/${FPATHVALUES[$i]}"
    IFILE="${NAME}_${IFILEVAL}"
    BFILE="${NAME}_${BFILEVAL}"
    AFILE="${NAME}_${AFILEVAL}"
    SFILE="${NAME}_${SFILEVAL}"
    TSFILE="${NAME}_$TSFILEVAL"
    DSFILE="${NAME}_$DSFILEVAL"
    DOFILE="${NAME}_$DOFILEVAL"
    EXAMPLE="example_$NAME.xml"
    GENERATED="generated_$NAME.xml"
    XMLNAME="Test_$NAME.xml"
    toexec="${BUILDER[$i]} --initialconditions $IFILE --boundaryconditions $BFILE -o $XMLNAME"
    if [ -f $SFILE ]; then toexec="$toexec --sourceconditions $SFILE";  fi
    if [ -f $TSFILE ]; then toexec="$toexec --tempsourceconditions $TSFILE"; fi
    if [ -f $DSFILE ]; then toexec="$toexec --domainsurfaces $DSFILE"; fi
    if [ -f $DOFILE ]; then toexec="$toexec --domainobstacles $DOFILE"; fi
    if [ -f $AFILE ]; then toexec="$toexec --adaption --adaptionparameter ${NAME}_$AFILEVAL"; fi
    if [ -f $XMLNAME ]
    then
      if [ $CLEAR -eq 1 ]
      then
        rm $XMLNAME
      else
        echo -e "${RED}$XMLNAME already exist.${NC}\n-> Please select '--overwrite' to overwrite existing file"
        continue
      fi
    fi

    $toexec
    xsltproc strip_comments.xsl Test_${NAME}.xml > 1.xml
    xsltproc strip_comments.xsl $FPATH/Test_${NAME}.xml > 2.xml
    xmllint --format 1.xml > 1_format.xml
    xmllint --format 2.xml > 2_format.xml
    tidy -xml -iq 1_format.xml > "$GENERATED"
    tidy -xml -iq 2_format.xml > "$EXAMPLE"
    if [ $VERBOSE -eq 1 ]
    then
      diff $GENERATED $EXAMPLE
    fi
    COUNT=$(diff $GENERATED $EXAMPLE | wc -l)
    if [ $COUNT -eq 0 ]
    then
      echo -e "${GREEN}successful${NC} [$NAME]"
      rm $EXAMPLE $GENERATED
    else
      echo -e "${RED}failure${NC} [$NAME]\n"
      FAIL=1
    fi
    if [ $GENERATE -eq 1 ]
    then
      # format?
      xmllint --format $XMLNAME > Format_${XMLNAME}
      #mv ${XMLNAME}_2 ${XMLNAME}
    else
      rm $XMLNAME
    fi
    if [ $GENERATE -eq 0 -o $VERBOSE -eq 0 ]
    then
      if [ -f $SFILE ]; then rm $SFILE; fi
      if [ -f $TSFILE ]; then rm $TSFILE; fi
      if [ -f $DSFILE ]; then rm $DSFILE; fi
      if [ -f $DOFILE ]; then rm $DOFILE; fi
      if [ -f $AFILE ]; then rm $AFILE; fi
      rm $BFILE $IFILE
    fi
    rm {1,2}{,_format}.xml
  done
  ALLXML=$(ls -R .. | grep -e '\.xml' | wc -l)
  echo "XML Files: $INDEX/$ALLXML"
  if [ $CLEAN -eq 0 ]
  then
    rm *.xml
  fi

  if [ $FAIL -eq 0 ]
  then
    exit 1
  else
    exit 0
  fi
