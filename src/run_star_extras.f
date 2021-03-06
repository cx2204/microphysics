!  ***********************************************************************
!
!   Copyright (C) 2010-2019  Bill Paxton & The MESA Team
!
!   this file is part of mesa.
!
!   mesa is free software; you can redistribute it and/or modify
!   it under the terms of the gnu general library public license as published
!   by the free software foundation; either version 2 of the license, or
!   (at your option) any later version.
!
!   mesa is distributed in the hope that it will be useful, 
!   but without any warranty; without even the implied warranty of
!   merchantability or fitness for a particular purpose.  see the
!   gnu library general public license for more details.
!
!   you should have received a copy of the gnu library general public license
!   along with this software; if not, write to the free software
!   foundation, inc., 59 temple place, suite 330, boston, ma 02111-1307 usa
!
! ***********************************************************************
 
      module run_star_extras

      use star_lib
      use star_def
      use const_def
      use math_lib
      ! use eos_lib
      ! use chem_def
  
      implicit none
      
      ! these routines are called by the standard run_star check_model
      contains
      subroutine extras_controls(id, ierr)
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         
         ! this is the place to set any procedure pointers you want to change
         ! e.g., other_wind, other_mixing, other_energy  (see star_data.inc)


         ! the extras functions in this file will not be called
         ! unless you set their function pointers as done below.
         ! otherwise we use a null_ version which does nothing (except warn).

         ! use eos_lib, only: eosDT_get_Rho

         s% extras_startup => extras_startup
         s% extras_start_step => extras_start_step
         s% extras_check_model => extras_check_model
         s% extras_finish_step => extras_finish_step
         s% extras_after_evolve => extras_after_evolve
         s% how_many_extra_history_columns => how_many_extra_history_columns
         s% data_for_extra_history_columns => data_for_extra_history_columns
         s% how_many_extra_profile_columns => how_many_extra_profile_columns
         s% data_for_extra_profile_columns => data_for_extra_profile_columns  

         s% how_many_extra_history_header_items => how_many_extra_history_header_items
         s% data_for_extra_history_header_items => data_for_extra_history_header_items
         s% how_many_extra_profile_header_items => how_many_extra_profile_header_items
         s% data_for_extra_profile_header_items => data_for_extra_profile_header_items
      

      ! edit the extras_controls routine to set the procedure pointers
      ! e.g.,
       !  s% other_eosDT_get => my_eosDT_get
       !  s% other_eosDT_get_Rho => my_eosDT_get_Rho
       !  s% other_eosPT_get => my_eosPT_get
       !  s% other_eosDT_get_T => my_eosDT_get_T

       !  s% other_kap_get => artificially_high_Z_kap_get

       !  s% other_net_get => my_net_get

end subroutine extras_controls
      
      
! kap subroutine.
         subroutine artificially_high_Z_kap_get( &
               id, k, handle, zbar, X, Z, Zbase, XC, XN, XO, XNe, &
               log10_rho, log10_T, species, chem_id, net_iso, xa, &
               lnfree_e, d_lnfree_e_dlnRho, d_lnfree_e_dlnT, &
               frac_Type2, kap, dln_kap_dlnRho, dln_kap_dlnT, ierr)
 ! #######################
            use const_def, only: dp
            ! the line below was added so that we can call the kap_get function
            use kap_lib, only: kap_get
! ########################
            ! INPUT
            integer, intent(in) :: id ! star id if available; 0 otherwise
            integer, intent(in) :: k ! cell number or 0 if not for a particular cell
            integer, intent(in) :: handle ! from alloc_kap_handle
            real(dp), intent(in) :: zbar ! average ion charge
            real(dp), intent(in) :: X, Z, Zbase, XC, XN, XO, XNe ! composition
            real(dp), intent(in) :: log10_rho ! density
            real(dp), intent(in) :: log10_T ! temperature
            real(dp), intent(in) :: lnfree_e, d_lnfree_e_dlnRho, d_lnfree_e_dlnT
               ! free_e := total combined number per nucleon of free electrons and positrons
            
            ! define new variables
            real(dp) :: Z_mod, Zbase_mod, XC_mod, XN_mod, XO_mod, XNe_mod

            integer, intent(in) :: species
            integer, pointer :: chem_id(:) ! maps species to chem id
               ! index from 1 to species
               ! value is between 1 and num_chem_isos
            integer, pointer :: net_iso(:) ! maps chem id to species number
               ! index from 1 to num_chem_isos (defined in chem_def)
               ! value is 0 if the iso is not in the current net
               ! else is value between 1 and number of species in current net
            real(dp), intent(in) :: xa(:) ! mass fractions

            ! OUTPUT
            real(dp), intent(out) :: frac_Type2
            real(dp), intent(out) :: kap ! opacity
            real(dp), intent(out) :: dln_kap_dlnRho ! partial derivative at constant T
            real(dp), intent(out) :: dln_kap_dlnT   ! partial derivative at constant Rho
            integer, intent(out) :: ierr ! 0 means AOK.

!  frac_Type2 = 0; kap = 0; dln_kap_dlnRho = 0; dln_kap_dlnT = 0

!  write(*,*) 'no implementation for other_kap_get'
!  ierr = -1
! ####################### 
            ! try hardcode these from the initial values of the high Z models
            ! Z, Zbase, XC, XN, XO, XNe
            Z_mod = max(0.04000000000000914,Z)
            Zbase_mod =  0.04
            XC_mod = 0.00688321465135668
            XN_mod = 0.002016317041128345
            XO_mod = 0.018720898559548563
            XNe_mod = 0.004198920956668217

            ! this you want to evolve
            ! X

            !try not touch *lnfree_e* at first

            ! This is to do exactly what MESA would normally do
            call kap_get( &
                 id, zbar, X, Z_mod, Zbase_mod, XC_mod, XN_mod, XO_mod, XNe_mod, &
                 log10_Rho, log10_T, lnfree_e, d_lnfree_e_dlnRho, d_lnfree_e_dlnT, &
                 frac_Type2, kap, dln_kap_dlnRho, dln_kap_dlnT, ierr)

         end subroutine artificially_high_Z_kap_get
! kap routine end.

! epsilon nuc routine begins

      subroutine my_net_get(  &
            id, k, net_handle, just_dxdt, n, num_isos, num_reactions,  &
            x, temp, log10temp, rho, log10rho,  &
            abar, zbar, z2bar, ye, eta, d_eta_dlnT, d_eta_dlnRho, &
            rate_factors, weak_rate_factor, &
            reaction_Qs, reaction_neuQs, reuse_rate_raw, reuse_rate_screened, &
            eps_nuc, d_eps_nuc_dRho, d_eps_nuc_dT, d_eps_nuc_dx,  &
            dxdt, d_dxdt_dRho, d_dxdt_dT, d_dxdt_dx,  &
            screening_mode, theta_e_for_graboske_et_al,  &
            eps_nuc_categories, eps_neu_total, &
            lwork, work, ierr)
         
         ! use const_def, only: dp
         use net_lib, only: net_get
         use net_def, only: Net_Info
         ! logical :: exist
         ! use chem_def 
 
         integer, intent(in) :: id ! id for star
         integer, intent(in) :: k ! cell number or 0 if not for a particular cell
         integer, intent(in) :: net_handle
         logical, intent(in) :: just_dxdt
         type (Net_Info), pointer:: n
         integer, intent(in) :: num_isos
         integer, intent(in) :: num_reactions
         real(dp), intent(in)  :: x(:) ! (num_isos)
         real(dp), intent(in)  :: temp, log10temp ! log10 of temp
         real(dp), intent(in)  :: rho, log10rho ! log10 of rho
         real(dp), intent(in)  :: abar  ! mean number of nucleons per nucleus
         real(dp), intent(in)  :: zbar  ! mean charge per nucleus
         real(dp), intent(in)  :: z2bar ! mean charge squared per nucleus
         real(dp), intent(in)  :: ye
         real(dp), intent(in)  :: eta, d_eta_dlnT, d_eta_dlnRho ! electron degeneracy from eos.
         real(dp), intent(in), pointer :: rate_factors(:) ! (num_reactions)
         real(dp), intent(in) :: weak_rate_factor
         real(dp), pointer, intent(in) :: reaction_Qs(:) ! (rates_reaction_id_max)
         real(dp), pointer, intent(in) :: reaction_neuQs(:) ! (rates_reaction_id_max)
         logical, intent(in) :: reuse_rate_raw, reuse_rate_screened ! if true. use given rate_screened

         real(dp), intent(out) :: eps_nuc ! ergs/g/s from burning after subtract reaction neutrinos
         real(dp), intent(out) :: d_eps_nuc_dT
         real(dp), intent(out) :: d_eps_nuc_dRho
         real(dp), intent(inout) :: d_eps_nuc_dx(:) ! (num_isos)
         real(dp), intent(inout) :: dxdt(:) ! (num_isos)
         real(dp), intent(inout) :: d_dxdt_dRho(:) ! (num_isos)
         real(dp), intent(inout) :: d_dxdt_dT(:) ! (num_isos)
         real(dp), intent(inout) :: d_dxdt_dx(:,:) ! (num_isos, num_isos)
         real(dp), intent(inout) :: eps_nuc_categories(:) ! (num_categories)
         real(dp), intent(out) :: eps_neu_total ! ergs/g/s neutrinos from weak reactions
         integer, intent(in) :: screening_mode
         real(dp), intent(in)  :: theta_e_for_graboske_et_al
         integer, intent(in) :: lwork ! size of work >= result from calling net_work_size
         real(dp), pointer :: work(:) ! (lwork)
         integer, intent(out) :: ierr ! 0 means okay
        
	 ! define new arguments

	 real(dp) :: x_new(8)
         real(dp) :: num_nucleon(8), num_charge(8), num_charge_sq(8)
	 real(dp) :: ion_abun(8), num_density(8)
	 real(dp) :: abar_new, zbar_new, z2bar_new 

         real(dp) :: metals, z_high, r_nonmetal, r_metal
	 ! r_metal = 200.6406153 ! Z_eps=0.02
	 r_metal = 2.0
	 metals = SUM(x(4:))
	 z_high = r_metal * metals

         ! !!!! routine that changes both H and He abundances
         r_nonmetal = (1 - metals) / (1 - z_high)
         if (z_high > metals) then
                x_new = [x(:3) / r_nonmetal, x(4:) * r_metal]
         endif

         ! !!!! routine that only changes H but not He
         ! r_h = (1 - z_high - x(2) - x(3)) / x(1)
         ! if (z_high > metals) then
         !       x_new = [x(1) * r_h, x(2), x(3), x(4:) * r_metal]
         ! endif

	 num_nucleon = (/1,3,4,12,14,16,20,24/) ! A(i)
	 num_charge = (/1,2,2,6,7,8,10,12/) ! Z(i)
         num_charge_sq = (/1,4,4,36,49,64,100,144/) ! Z(i)^2
       

         ! definitions from chem_lib.f90, get_composition_info subroutine.

	 ion_abun = x_new / num_nucleon ! Y(i)
	 num_density = ion_abun * avo * rho ! n(i)
         
	 abar_new = SUM(num_density * num_nucleon) / SUM(num_density)
	 zbar_new = SUM(num_density * num_charge) / SUM(num_density)
	 z2bar_new = SUM(num_density * num_charge ** 2) / SUM(num_density) 

	 ! print *, x
	 ! print *, x_new
	 print *, abar
	 print *, abar_new

         call net_get( &
            net_handle, just_dxdt, n, num_isos, num_reactions,  &
            x_new, temp, log10temp, rho, log10rho,  &
            abar_new, zbar_new, z2bar_new, ye, eta, d_eta_dlnT, d_eta_dlnRho, &
            rate_factors, weak_rate_factor, &
            reaction_Qs, reaction_neuQs, reuse_rate_raw, reuse_rate_screened, &
            eps_nuc, d_eps_nuc_dRho, d_eps_nuc_dT, d_eps_nuc_dx,  &
            dxdt, d_dxdt_dRho, d_dxdt_dT, d_dxdt_dx,  &
            screening_mode, theta_e_for_graboske_et_al,  &
            eps_nuc_categories, eps_neu_total, &
            lwork, work, ierr)

	  ! STOP "check"

      end subroutine my_net_get


! epsilon nuc routine ends

! eos routine begins.

      subroutine my_eosDT_get( &
              id, k, handle, Z, X, abar, zbar, & 
              species, chem_id, net_iso, xa, &
              Rho, log10Rho, T, log10T, & 
              res, d_dlnRho_const_T, d_dlnT_const_Rho, &
              d_dabar_const_TRho, d_dzbar_const_TRho, ierr)
         ! use const_def, only: dp        

         ! INPUT
         use chem_def, only: num_chem_isos
         use eos_lib         
         integer, intent(in) :: id ! star id if available; 0 otherwise
         integer, intent(in) :: k ! cell number or 0 if not for a particular cell         
         integer, intent(in) :: handle ! eos handle

         real(dp), intent(in) :: Z ! the metals mass fraction
         real(dp), intent(in) :: X ! the hydrogen mass fraction
 
         real(dp), intent(in) :: abar
            ! mean atomic number (nucleons per nucleus; grams per mole)
         real(dp), intent(in) :: zbar ! mean charge per nucleus

         real(dp), intent(in) :: xa(:), Rho, log10Rho, T, log10T
         
         integer, intent(in) :: species
         integer, pointer :: chem_id(:) ! maps species to chem id
         integer, pointer :: net_iso(:) ! maps chem id to species number
            
         real(dp) :: Z_mod

         ! OUTPUT
         
         real(dp), intent(inout) :: res(:) ! (num_eos_basic_results)
         real(dp), intent(inout) :: d_dlnRho_const_T(:) ! (num_eos_basic_results)  
         real(dp), intent(inout) :: d_dlnT_const_Rho(:) ! (num_eos_basic_results) 
         real(dp), intent(inout) :: d_dabar_const_TRho(:) ! (num_eos_basic_results) 
         real(dp), intent(inout) :: d_dzbar_const_TRho(:) ! (num_eos_basic_results) 

         integer, intent(out) :: ierr ! 0 means AOK.

         ! print *, s% gamma_law_hydro, ">0?"
         ! print *, s% use_eosDT_ideal_gas, "true?"
         ! print *, s% use_eosDT_HELMEOS, "true?"
         
         ! print *, z
         ! print *, res

         Z_mod = max(0.04,Z)
         ! print *, Z_mod

       call eosDT_get( &
            handle, Z_mod, X, abar, zbar, &
            species, chem_id, net_iso, xa, &
            Rho, log10Rho, T, log10T, &
            res, d_dlnRho_const_T, d_dlnT_const_Rho, & 
            d_dabar_const_TRho, d_dzbar_const_TRho, ierr)
        ! print *, res
        ! STOP

      end subroutine my_eosDT_get

         subroutine my_eosDT_get_Rho( &
                  id, k, handle, Z, X, abar, zbar, &
                  species, chem_id, net_iso, xa, &
                  logT, which_other, other_value, &
                  logRho_tol, other_tol, max_iter, logRho_guess,  &
                  logRho_bnd1, logRho_bnd2, other_at_bnd1, other_at_bnd2, &
                  logRho_result, res, d_dlnRho_const_T, d_dlnT_const_Rho, &
                  d_dabar_const_TRho, d_dzbar_const_TRho, &
                  eos_calls, ierr)
    
            ! finds log10 Rho given values for temperature and 'other', and initial guess for density.
            ! does up to max_iter attempts until logRho changes by less than tol.

            ! 'other' can be any of the basic result variables for the eos
            ! specify 'which_other' by means of the definitions in eos_def (e.g., i_lnE)

            use eos_lib, only: eosDT_get_Rho
            use const_def, only: dp

            integer, intent(in) :: id ! star id if available; 0 otherwise
            integer, intent(in) :: k ! cell number or 0 if not for a particular cell    
            integer, intent(in) :: handle

            real(dp), intent(in) :: Z ! the metals mass fraction
            real(dp), intent(in) :: X ! the hydrogen mass fraction

            real(dp), intent(in) :: abar
               ! mean atomic number (nucleons per nucleus; grams per mole)
            real(dp), intent(in) :: zbar ! mean charge per nucleus

            integer, intent(in) :: species
            integer, pointer :: chem_id(:) ! maps species to chem id
               ! index from 1 to species
               ! value is between 1 and num_chem_isos
            integer, pointer :: net_iso(:) ! maps chem id to species number
               ! index from 1 to num_chem_isos (defined in chem_def)
               ! value is 0 if the iso is not in the current net
               ! else is value between 1 and number of species in current net
            real(dp), intent(in) :: xa(:) ! mass fractions

            real(dp), intent(in) :: logT ! log10 of temperature

            integer, intent(in) :: which_other ! from eos_def.  e.g., i_lnE
            real(dp), intent(in) :: other_value ! desired value for the other variable
            real(dp), intent(in) :: other_tol

            real(dp), intent(in) :: logRho_tol

            integer, intent(in) :: max_iter ! max number of Newton iterations

            real(dp), intent(in) :: logRho_guess ! log10 of density
            real(dp), intent(in) :: logRho_bnd1, logRho_bnd2 ! bounds for logRho
               ! if don't know bounds, just set to arg_not_provided (defined in const_def)
            real(dp), intent(in) :: other_at_bnd1, other_at_bnd2 ! values at bounds
               ! if don't know these values, just set to arg_not_provided (defined in const_def)

            real(dp), intent(out) :: logRho_result ! log10 of density

            real(dp), intent(inout) :: res(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dlnRho_const_T(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dlnT_const_Rho(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dabar_const_TRho(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dzbar_const_TRho(:) ! (num_eos_basic_results)

            integer, intent(out) :: eos_calls
            integer, intent(out) :: ierr ! 0 means AOK.

            ! print *, res

            call eosDT_get_Rho( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logT, which_other, other_value, &
               logRho_tol, other_tol, max_iter, logRho_guess, &
               logRho_bnd1, logRho_bnd2, other_at_bnd1, other_at_bnd2, &
               logRho_result, res, d_dlnRho_const_T, d_dlnT_const_Rho, &
               !eos_calls, ierr)
               d_dabar_const_TRho, d_dzbar_const_TRho, eos_calls, ierr)
            ! STOP
         end subroutine my_eosDT_get_Rho

         subroutine my_eosPT_get(&
                  id, k, handle, Z, X, abar, zbar, &
                  species, chem_id, net_iso, xa,&
                  Pgas, log10Pgas, T, log10T, &
                  Rho, log10Rho, dlnRho_dlnPgas_const_T, dlnRho_dlnT_const_Pgas, &
                  res, d_dlnRho_const_T, d_dlnT_const_Rho, &
                  d_dabar_const_TRho, d_dzbar_const_TRho, ierr)
            use const_def, only: dp
	    use eos_lib, only: eosPT_get, eos_ptr
            ! INPUT

            integer, intent(in) :: id ! star id if available; 0 otherwise
            integer, intent(in) :: k ! cell number or 0 if not for a particular cell
            integer, intent(in) :: handle

            real(dp), intent(in) :: Z ! the metals mass fraction
            real(dp), intent(in) :: X ! the hydrogen mass fraction

            real(dp), intent(in) :: abar
               ! mean atomic number (nucleons per nucleus; grams per mole)
            real(dp), intent(in) :: zbar ! mean charge per nucleus

            integer, intent(in) :: species
            integer, pointer :: chem_id(:) ! maps species to chem id
               ! index from 1 to species
               ! value is between 1 and num_chem_isos
            integer, pointer :: net_iso(:) ! maps chem id to species number
               ! index from 1 to num_chem_isos (defined in chem_def)
               ! value is 0 if the iso is not in the current net
               ! else is value between 1 and number of species in current net
            real(dp), intent(in) :: xa(:) ! mass fractions

            real(dp), intent(in) :: Pgas, log10Pgas ! the gas pressure
               ! provide both if you have them.  else pass one and set the other to arg_not_provided
               ! "arg_not_provided" is defined in mesa const_def

            real(dp), intent(in) :: T, log10T ! the temperature
               ! provide both if you have them.  else pass one and set the other to arg_not_provided
     
            type (EoS_General_Info), pointer :: rq
    
            ! OUTPUT

            real(dp), intent(out) :: Rho, log10Rho ! density
            real(dp), intent(out) :: dlnRho_dlnPgas_const_T
            real(dp), intent(out) :: dlnRho_dlnT_const_Pgas
            real(dp), intent(inout) :: res(:) ! (num_eos_basic_results)
            ! partial derivatives of the basic results wrt lnd and lnT
            real(dp), intent(inout) :: d_dlnRho_const_T(:) ! (num_eos_basic_results)
            ! d_dlnRho_const_T(i) = d(res(i))/dlnd|T
            real(dp), intent(inout) :: d_dlnT_const_Rho(:) ! (num_eos_basic_results)
            ! d_dlnT_const_Rho(i) = d(res(i))/dlnT|Rho
            real(dp), intent(inout) :: d_dabar_const_TRho(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dzbar_const_TRho(:) ! (num_eos_basic_results)
            

            integer, intent(out) :: ierr ! 0 means AOK.
          call eos_ptr(handle,rq,ierr)  
            ! print *, res

          call eosPT_get( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               Pgas, log10Pgas, T, log10T, &
               Rho, log10Rho, dlnRho_dlnPgas_const_T, dlnRho_dlnT_const_Pgas, &
               res, d_dlnRho_const_T, d_dlnT_const_Rho, &
               !ierr)
               d_dabar_const_TRho, d_dzbar_const_TRho, ierr)
           ! STOP
         end subroutine my_eosPT_get

         subroutine my_eosDT_get_T( &
                  id, k, handle, Z, X, abar, zbar, &
                  species, chem_id, net_iso, xa, &
                  logRho, which_other, other_value, &
                  logT_tol, other_tol, max_iter, logT_guess, &
                  logT_bnd1, logT_bnd2, other_at_bnd1, other_at_bnd2, &
                  logT_result, res, d_dlnRho_const_T, d_dlnT_const_Rho, &
                  d_dabar_const_TRho, d_dzbar_const_TRho, &
                  eos_calls, ierr)
            use const_def, only: dp
            use eos_lib, only: eosDT_get_T

            integer, intent(in) :: id ! star id if available; 0 otherwise
            integer, intent(in) :: k ! cell number or 0 if not for a particular cell
            integer, intent(in) :: handle

            real(dp), intent(in) :: Z ! the metals mass fraction
            real(dp), intent(in) :: X ! the hydrogen mass fraction

            real(dp), intent(in) :: abar
            real(dp), intent(in) :: zbar ! mean charge per nucleus

            integer, intent(in) :: species
            integer, pointer :: chem_id(:) ! maps species to chem id
            integer, pointer :: net_iso(:) ! maps chem id to species number
            real(dp), intent(in) :: xa(:) ! mass fractions

            real(dp), intent(in) :: logRho ! log10 of density
            integer, intent(in) :: which_other ! from eos_def.  e.g., i_lnE
            real(dp), intent(in) :: other_value ! desired value for the other variable
            real(dp), intent(in) :: other_tol

            real(dp), intent(in) :: logT_tol
            integer, intent(in) :: max_iter ! max number of iterations

            real(dp), intent(in) :: logT_guess ! log10 of temperature
            real(dp), intent(in) :: logT_bnd1, logT_bnd2 ! bounds for logT
            real(dp), intent(in) :: other_at_bnd1, other_at_bnd2 ! values at bounds

            real(dp), intent(out) :: logT_result ! log10 of temperature
            real(dp), intent(inout) :: res(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dlnRho_const_T(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dlnT_const_Rho(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dabar_const_TRho(:) ! (num_eos_basic_results)
            real(dp), intent(inout) :: d_dzbar_const_TRho(:) ! (num_eos_basic_results)

            integer, intent(out) :: eos_calls
            integer, intent(out) :: ierr ! 0 means AOK.

            call eosDT_get_T( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logRho, which_other, other_value, &
               logT_tol, other_tol, max_iter, logT_guess, &
               logT_bnd1, logT_bnd2, other_at_bnd1, other_at_bnd2, &
               logT_result, res, d_dlnRho_const_T, d_dlnT_const_Rho, &
               !eos_calls, ierr)
               d_dabar_const_TRho, d_dzbar_const_TRho, eos_calls, ierr)

         end subroutine my_eosDT_get_T

! eos routine ends.


      subroutine extras_startup(id, restart, ierr)
         integer, intent(in) :: id
         logical, intent(in) :: restart
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return

         ! character (len=60) :: file_name = "/Users/cxin/Documents/Stars/data/eps_nuc_z0.02_ms.txt"
         ! real :: eps_nuc_data(924)
         ! integer :: unit

         ! inquire(file=file_name,exist=exist)

         ! i = 0
         ! if (exist) then
         ! OPEN(unit=11, file=file_name,status='old',action='read',iostat=ierr)
         ! do i=1, size(eps_nuc_data)
               ! i = i + 1
         !      READ(11,'es12.6',iostat=ierr) eps_nuc_data(i)
         !      print *, 'a', eps_nuc_data(i)
         !      s% xtra1_array(i) = eps_nuc_data(i)
         ! enddo
         ! close(11)
         ! end if
        
      end subroutine extras_startup
      

      integer function extras_start_step(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s

         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_start_step = 0
	 ! print *, s% model_number

         !if (s% model_number >= 1005) then
         !       s% use_other_net_get = .true.
		! print *, s% model_number
	 !else 
	 	! print *, "nope"
         !endif

	 !print *, s% model_number

      end function extras_start_step


      ! returns either keep_going, retry, backup, or terminate.
      integer function extras_check_model(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_check_model = keep_going         
         if (.false. .and. s% star_mass_h1 < 0.35d0) then
            ! stop when star hydrogen mass drops to specified level
            extras_check_model = terminate
            write(*, *) 'have reached desired hydrogen mass'
            return
         end if


         ! if you want to check multiple conditions, it can be useful
         ! to set a different termination code depending on which
         ! condition was triggered.  MESA provides 9 customizeable
         ! termination codes, named t_xtra1 .. t_xtra9.  You can
         ! customize the messages that will be printed upon exit by
         ! setting the corresponding termination_code_str value.
         ! termination_code_str(t_xtra1) = 'my termination condition'

         ! by default, indicate where (in the code) MESA terminated
         if (extras_check_model == terminate) s% termination_code = t_extras_check_model
      end function extras_check_model


      integer function how_many_extra_history_columns(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_history_columns = 4
      end function how_many_extra_history_columns
   
         ! I started editing here.     
      subroutine data_for_extra_history_columns(id, n, names, vals, ierr)

           use math_lib, only: safe_log10
           use chem_def, only: ih1

           integer, intent(in) :: id, n
           character (len=maxlen_history_column_name) :: names(n)
           real(dp) :: vals(n)
           integer, intent(out) :: ierr
           type (star_info), pointer :: s

           integer :: i
           real(dp) :: mu_ave ! mass average mean molecular weight
           real(dp) :: kap_ave ! flux averaged opacity in radiative region
           real(dp) :: f_rad, f_tot, m_conv_tot, aux_var

           ierr = 0
           call star_ptr(id, s, ierr)
           if (ierr /= 0) return

           mu_ave = 0
           do i = s% nz, 1, -1
              mu_ave = mu_ave + s% mu(i) * s% dm(i)
           end do

           kap_ave = 0
           f_tot = 0
           do i = s% nz, -1, 1
              if (s% mixing_type(i) == 0) then
                 f_rad = s% L(i) / (4 * pi * (s% r(i) ** 2))
                 kap_ave = kap_ave + f_rad * s% opacity(i)
                 f_tot = f_tot + f_rad
              endif      
           end do

           ! r_conv_tot = 0

           aux_var = 0
           m_conv_tot = 0
           ! if (s% xa(s% net_iso(ih1), s% nz) > 0.6) then
           do i = 1, s% nz, 1
                if (s% xa(s% net_iso(ih1), i) > 0.6) then
                        if (s% mixing_type(i) == 1) then
                                m_conv_tot = m_conv_tot + s% dm(i)
                        aux_var = 0
                        else
                                aux_var = aux_var + s% dm(i)
                        endif
                else
                        exit
                endif

                if (aux_var >= 3 * msol) then
                        exit
                endif
           end do


           ! endif
           ! kap_ave = kap_ave / f_tot

           ! print *, mu_ave
           names(1) = "mu_int"
           ! vals(1) = mu_ave / SUM(s% dm,DIM=1)
           vals(1) = mu_ave / (s% star_mass * msol)

           names(2) = "mu_tot"
           vals(2) = mu_ave

           names(3) = "kap_ave"
           vals(3) = kap_ave / f_tot

           names(4) = "m_conv_tot"
           vals(4) = m_conv_tot

           ierr = 0
      end subroutine data_for_extra_history_columns


      integer function how_many_extra_profile_columns(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_profile_columns = 0
      end function how_many_extra_profile_columns
      
      
      subroutine data_for_extra_profile_columns(id, n, nz, names, vals, ierr)
         integer, intent(in) :: id, n, nz
         character (len=maxlen_profile_column_name) :: names(n)
         real(dp) :: vals(nz,n)
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         integer :: k
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         
         ! note: do NOT add the extra names to profile_columns.list
         ! the profile_columns.list is only for the built-in profile column options.
         ! it must not include the new column names you are adding here.

         ! here is an example for adding a profile column
         !if (n /= 1) stop 'data_for_extra_profile_columns'
         !names(1) = 'beta'
         !do k = 1, nz
         !   vals(k,1) = s% Pgas(k)/s% P(k)
         !end do
         
      end subroutine data_for_extra_profile_columns


      integer function how_many_extra_history_header_items(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_history_header_items = 0
      end function how_many_extra_history_header_items


      subroutine data_for_extra_history_header_items(id, n, names, vals, ierr)
         integer, intent(in) :: id, n
         character (len=maxlen_history_column_name) :: names(n)
         real(dp) :: vals(n)
         type(star_info), pointer :: s
         integer, intent(out) :: ierr
         ierr = 0
         call star_ptr(id,s,ierr)
         if(ierr/=0) return

         ! here is an example for adding an extra history header item
         ! also set how_many_extra_history_header_items
         ! names(1) = 'mixing_length_alpha'
         ! vals(1) = s% mixing_length_alpha

      end subroutine data_for_extra_history_header_items


      integer function how_many_extra_profile_header_items(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_profile_header_items = 0
      end function how_many_extra_profile_header_items


      subroutine data_for_extra_profile_header_items(id, n, names, vals, ierr)
         integer, intent(in) :: id, n
         character (len=maxlen_profile_column_name) :: names(n)
         real(dp) :: vals(n)
         type(star_info), pointer :: s
         integer, intent(out) :: ierr
         ierr = 0
         call star_ptr(id,s,ierr)
         if(ierr/=0) return

         ! here is an example for adding an extra profile header item
         ! also set how_many_extra_profile_header_items
         ! names(1) = 'mixing_length_alpha'
         ! vals(1) = s% mixing_length_alpha

      end subroutine data_for_extra_profile_header_items


      ! returns either keep_going or terminate.
      ! note: cannot request retry or backup; extras_check_model can do that.
      integer function extras_finish_step(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_finish_step = keep_going

         ! to save a profile, 
            ! s% need_to_save_profiles_now = .true.
         ! to update the star log,
            ! s% need_to_update_history_now = .true.

         ! see extras_check_model for information about custom termination codes
         ! by default, indicate where (in the code) MESA terminated
         if (extras_finish_step == terminate) s% termination_code = t_extras_finish_step
      end function extras_finish_step
      
      
      subroutine extras_after_evolve(id, ierr)
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
      end subroutine extras_after_evolve

      
      
      end module run_star_extras
