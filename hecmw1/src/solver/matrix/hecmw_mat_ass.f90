!======================================================================!
!                                                                      !
!   Software Name : HEC-MW Library for PC-cluster                      !
!         Version : 2.7                                                !
!                                                                      !
!     Last Update : 2007/10/30                                         !
!        Category : Matrix Operation                                   !
!                                                                      !
!            Written by Yasuji Fukahori (Univ. of Tokyo)               !
!                       Kazuya Goto (Univ. of Tokyo)                   !
!                                                                      !
!     Contact address :  IIS,The University of Tokyo RSS21 project     !
!                                                                      !
!     "Structural Analysis System for General-purpose Coupling         !
!      Simulations Using High End Computing Middleware (HEC-MW)"       !
!                                                                      !
!======================================================================!

module hecmw_matrix_ass
   use hecmw_util
   use m_hecmw_comm_f
   use hecmw_matrix_misc
   use hecmw_matrix_contact
   implicit none

   private

   public :: hecmw_mat_ass_elem
   public :: hecmw_mat_add_node
   public :: hecmw_array_search_i
   public :: hecmw_mat_ass_equation
   public :: hecmw_mat_add_dof
   public :: hecmw_mat_ass_bc
   public :: hecmw_mat_ass_contact
   public :: stf_get_block

   contains

!C
!C***
!C*** MAT_ASS_ELEM
!C***
!C
   subroutine hecmw_mat_ass_elem(hecMAT, nn, nodLOCAL, stiffness)
      type (hecmwST_matrix)     :: hecMAT
      integer(kind=kint) :: nn
      integer(kind=kint) :: nodLOCAL(:)
      real(kind=kreal) :: stiffness(:, :)
      !** Local variables
      integer(kind=kint) :: ndof, inod_e, jnod_e, inod, jnod
      real(kind=kreal) :: a(6,6)

      ndof = hecMAT%NDOF

      do inod_e = 1, nn
        inod = nodLOCAL(inod_e)
        do jnod_e = 1, nn
          jnod = nodLOCAL(jnod_e)
          !***** Add components
          call stf_get_block(stiffness, ndof, inod_e, jnod_e, a)
          call hecmw_mat_add_node(hecMAT, inod, jnod, a)
        enddo
      enddo

   end subroutine hecmw_mat_ass_elem

   subroutine stf_get_block(stiffness, ndof, inod, jnod, a)
      real(kind=kreal) :: stiffness(:, :), a(:, :)
      integer(kind=kint) :: ndof, inod, jnod
      !** Local variables
      integer(kind=kint) :: row_offset, col_offset, i, j

      row_offset = ndof*(inod-1)
      do i = 1, ndof

        col_offset = ndof*(jnod-1)
        do j = 1, ndof

          a(i, j) = stiffness(i + row_offset, j + col_offset)
        enddo
      enddo
   end subroutine stf_get_block


   subroutine hecmw_mat_add_node(hecMAT, inod, jnod, a)
      type (hecmwST_matrix) :: hecMAT
      integer(kind=kint) :: inod, jnod
      real(kind=kreal) :: a(:, :)
      !** Local variables
      integer(kind=kint) :: NDOF, iS, iE, k, idx_base, idx, idof, jdof

      NDOF = hecMAT%NDOF

      if (inod < jnod) then
        iS = hecMAT%indexU(inod-1)+1
        iE = hecMAT%indexU(inod)
        k = hecmw_array_search_i(hecMAT%itemU, iS, iE, jnod)

        if (k < iS .or. iE < k) then
          write(*,*) '###ERROR### : cannot find connectivity (1)'
          write(*,*) ' myrank = ', hecmw_comm_get_rank(), ', inod = ', inod, ', jnod = ', jnod
          call hecmw_abort(hecmw_comm_get_comm())
        endif

        idx_base = NDOF**2 * (k-1)
        do idof = 1, NDOF
          do jdof = 1, NDOF
            idx = idx_base + jdof
!$omp atomic
            hecMAT%AU(idx) = hecMAT%AU(idx) + a(idof, jdof)
          enddo
          idx_base = idx_base + NDOF
        enddo

      else if (inod > jnod) then
        iS = hecMAT%indexL(inod-1)+1
        iE = hecMAT%indexL(inod)
        k = hecmw_array_search_i(hecMAT%itemL, iS, iE, jnod)

        if (k < iS .or. iE < k) then
          write(*,*) '###ERROR### : cannot find connectivity (2)'
          write(*,*) ' myrank = ', hecmw_comm_get_rank(), ', inod = ', inod, ', jnod = ', jnod
          call hecmw_abort(hecmw_comm_get_comm())
        endif

        idx_base = NDOF**2 * (k-1)
        do idof = 1, NDOF
          do jdof = 1, NDOF
            idx = idx_base + jdof
!$omp atomic
            hecMAT%AL(idx) = hecMAT%AL(idx) + a(idof, jdof)
          enddo
          idx_base = idx_base + NDOF
        enddo

      else
        idx_base = NDOF**2 * (inod - 1)
        do idof = 1, NDOF
          do jdof = 1, NDOF
            idx = idx_base + jdof
!$omp atomic
            hecMAT%D(idx) = hecMAT%D(idx) + a(idof, jdof)
          enddo
          idx_base = idx_base + NDOF
        enddo
      endif
   end subroutine hecmw_mat_add_node


   function hecmw_array_search_i(array, iS, iE, ival)
      integer(kind=kint) :: hecmw_array_search_i
      integer(kind=kint) :: array(:)
      integer(kind=kint) :: iS, iE, ival
      !** Local variables
      integer(kind=kint) :: left, right, center, cval

      left = iS
      right = iE
      do
        if (left > right) then
          center = -1
          exit
        endif

        center = (left + right) / 2
        cval = array(center)

        if (ival < cval) then
          right = center - 1
        else if (cval < ival) then
          left = center + 1
        else
          exit
        endif
      enddo

      hecmw_array_search_i = center

   end function hecmw_array_search_i


!C
!C***
!C*** MAT_ASS_EQUATION
!C***
!C
   subroutine hecmw_mat_ass_equation ( hecMESH, hecMAT )
      type (hecmwST_matrix), target :: hecMAT
      type (hecmwST_local_mesh)     :: hecMESH
      !** Local variables
      real(kind=kreal), pointer :: penalty
      real(kind=kreal) :: ALPHA, a1_2inv, ai, aj, factor, ci
      integer(kind=kint) :: NDIAG, impc, iS, iE, i, j, inod, idof, jnod, jdof
      logical :: is_internal_i, is_internal_j

      if( hecmw_mat_get_penalized(hecMAT) == 1 .and. hecmw_mat_get_penalized_b(hecMAT) == 1) return

      ! write(*,*) "INFO: imposing MPC by penalty"

      penalty => hecMAT%Rarray(11)

      if (penalty < 0.0) stop "ERROR: negative penalty"
      if (penalty < 1.0) write(*,*) "WARNING: penalty ", penalty, " smaller than 1"

      ALPHA= hecmw_mat_diag_max(hecMAT, hecMESH) * penalty

      do impc = 1, hecMESH%mpc%n_mpc
        iS = hecMESH%mpc%mpc_index(impc-1) + 1
        iE = hecMESH%mpc%mpc_index(impc)
        a1_2inv = 1.0 / hecMESH%mpc%mpc_val(iS)**2

        do i = iS, iE
          inod = hecMESH%mpc%mpc_item(i)

          is_internal_i = (hecMESH%node_ID(2*inod) == hecmw_comm_get_rank())

          idof = hecMESH%mpc%mpc_dof(i)
          ai = hecMESH%mpc%mpc_val(i)
          factor = ai * a1_2inv

          if( hecmw_mat_get_penalized(hecMAT) == 0) then
            do j = iS, iE
              jnod = hecMESH%mpc%mpc_item(j)

              is_internal_j = (hecMESH%node_ID(2*jnod) == hecmw_comm_get_rank())
              if (.not. (is_internal_i .or. is_internal_j)) cycle

              jdof = hecMESH%mpc%mpc_dof(j)
              aj = hecMESH%mpc%mpc_val(j)

              call hecmw_mat_add_dof(hecMAT, inod, idof, jnod, jdof, aj*factor*ALPHA)
            enddo
          endif

          if( hecmw_mat_get_penalized_b(hecMAT) == 0) then
            ci = hecMESH%mpc%mpc_const(impc)
!$omp atomic
            hecMAT%B(3*(inod-1)+idof) = hecMAT%B(3*(inod-1)+idof) + ci*factor*ALPHA
          endif
        enddo
      enddo

      call hecmw_mat_set_penalized(hecMAT, 1)
      call hecmw_mat_set_penalized_b(hecMAT, 1)

   end subroutine hecmw_mat_ass_equation


   subroutine hecmw_mat_add_dof(hecMAT, inod, idof, jnod, jdof, val)
      type (hecmwST_matrix) :: hecMAT
      integer(kind=kint) :: inod, idof, jnod, jdof
      real(kind=kreal) :: val
      !** Local variables
      integer(kind=kint) :: NDOF, iS, iE, k, idx

      NDOF = hecMAT%NDOF
      if (inod < jnod) then
        iS = hecMAT%indexU(inod-1)+1
        iE = hecMAT%indexU(inod)
        k = hecmw_array_search_i(hecMAT%itemU, iS, iE, jnod)

        if (k < iS .or. iE < k) then
          write(*,*) '###ERROR### : cannot find connectivity (3)'
          write(*,*) '  myrank = ', hecmw_comm_get_rank(), ', inod = ', inod, ', jnod = ', jnod
          call hecmw_abort(hecmw_comm_get_comm())
          return
        endif

        idx = NDOF**2 * (k-1) + NDOF * (idof-1) + jdof
!$omp atomic
        hecMAT%AU(idx) = hecMAT%AU(idx) + val

      else if (inod > jnod) then
        iS = hecMAT%indexL(inod-1)+1
        iE = hecMAT%indexL(inod)
        k = hecmw_array_search_i(hecMAT%itemL, iS, iE, jnod)

        if (k < iS .or. iE < k) then
          write(*,*) '###ERROR### : cannot find connectivity (4)'
          write(*,*) ' myrank = ', hecmw_comm_get_rank(), ', inod = ', inod, ', jnod = ', jnod
          call hecmw_abort(hecmw_comm_get_comm())
          return
        endif

        idx = NDOF**2 * (k-1) + NDOF * (idof-1) + jdof
!$omp atomic
        hecMAT%AL(idx) = hecMAT%AL(idx) + val

      else
        idx = NDOF**2 * (inod - 1) + NDOF * (idof - 1) + jdof
!$omp atomic
        hecMAT%D(idx) = hecMAT%D(idx) + val
      endif

   end subroutine hecmw_mat_add_dof

!C
!C***
!C*** MAT_ASS_BC
!C***
!C
   subroutine hecmw_mat_ass_bc(hecMAT, inode, idof, RHS, conMAT)
      type (hecmwST_matrix)     :: hecMAT
      integer(kind=kint) :: inode, idof
      real(kind=kreal) :: RHS
      type (hecmwST_matrix),optional     :: conMAT
      integer(kind=kint) :: NDOF, in, i, ii, iii, ndof2, k, iS, iE, iiS, iiE, ik

      NDOF = hecMAT%NDOF
      if( NDOF < idof ) return

      !C-- DIAGONAL block

      hecMAT%B(NDOF*inode-(NDOF-idof)) = RHS
      if(present(conMAT)) conMAT%B(NDOF*inode-(NDOF-idof)) = 0.0D0
      ndof2 = NDOF*NDOF
      ii  = ndof2 - idof

      DO i = NDOF-1,0,-1
        IF( i .NE. NDOF-idof ) THEN
!$omp atomic
          hecMAT%B(NDOF*inode-i) = hecMAT%B(NDOF*inode-i)        &
                                 - hecMAT%D(ndof2*inode-ii)*RHS
          if(present(conMAT)) then
!$omp atomic
            conMAT%B(NDOF*inode-i) = conMAT%B(NDOF*inode-i)        &
                                   - conMAT%D(ndof2*inode-ii)*RHS
          endif
        ENDIF
        ii = ii - NDOF
      END DO

      !*Set diagonal row to zero
      ii  = ndof2-1 - (idof-1)*NDOF

      DO i = 0, NDOF - 1
        hecMAT%D(ndof2*inode-ii+i)=0.d0
        if(present(conMAT)) conMAT%D(ndof2*inode-ii+i)=0.d0
      END DO

      !*Set diagonal column to zero
      ii = ndof2 - idof
      DO i = 1, NDOF
        IF( i.NE.idof ) THEN
          hecMAT%D(ndof2*inode-ii) = 0.d0
          if(present(conMAT)) conMAT%D(ndof2*inode-ii) = 0.d0
        ELSE
          hecMAT%D(ndof2*inode-ii) = 1.d0
          if(present(conMAT)) conMAT%D(ndof2*inode-ii) = 0.d0
        ENDIF
        ii = ii - NDOF
      END DO

      !C-- OFF-DIAGONAL blocks

      ii  = ndof2-1 - (idof-1)*NDOF
      iS = hecMAT%indexL(inode-1) + 1
      iE = hecMAT%indexL(inode  )

      do k= iS, iE

        !*row (left)
        DO i = 0, NDOF - 1
          hecMAT%AL(ndof2*k-ii+i) = 0.d0
          if(present(conMAT)) conMAT%AL(ndof2*k-ii+i) = 0.d0
        END DO

        !*column (upper)
        in = hecMAT%itemL(k)
        iiS = hecMAT%indexU(in-1) + 1
        iiE = hecMAT%indexU(in  )
        do ik = iiS, iiE
          if (hecMAT%itemU(ik) .eq. inode) then
            iii = ndof2 - idof
            DO i = NDOF-1,0,-1
!$omp atomic
              hecMAT%B(NDOF*in-i) = hecMAT%B(NDOF*in-i)      &
                                  - hecMAT%AU(ndof2*ik-iii)*RHS
              hecMAT%AU(ndof2*ik-iii)= 0.d0
              if(present(conMAT)) then
!$omp atomic
                conMAT%B(NDOF*in-i) = conMAT%B(NDOF*in-i)      &
                                    - conMAT%AU(ndof2*ik-iii)*RHS
                conMAT%AU(ndof2*ik-iii)= 0.d0
              endif
              iii = iii - NDOF
            END DO
            exit
          endif
        enddo

      enddo

      ii = ndof2-1 - (idof-1)*NDOF
      iS = hecMAT%indexU(inode-1) + 1
      iE = hecMAT%indexU(inode  )

      do k= iS, iE

        !*row (right)
        DO i = 0,NDOF-1
          hecMAT%AU(ndof2*k-ii+i) = 0.d0
          if(present(conMAT)) conMAT%AU(ndof2*k-ii+i) = 0.d0
        END DO

        !*column (lower)
        in = hecMAT%itemU(k)
        iiS = hecMAT%indexL(in-1) + 1
        iiE = hecMAT%indexL(in  )
        do ik= iiS, iiE
          if (hecMAT%itemL(ik) .eq. inode) then
            iii  = ndof2 - idof

            DO i = NDOF-1, 0, -1
!$omp atomic
              hecMAT%B(NDOF*in-i) = hecMAT%B(NDOF*in-i)      &
                                  - hecMAT%AL(ndof2*ik-iii)*RHS
              hecMAT%AL(ndof2*ik-iii) = 0.d0
              if(present(conMAT)) then
!$omp atomic
                conMAT%B(NDOF*in-i) = conMAT%B(NDOF*in-i)      &
                                    - conMAT%AL(ndof2*ik-iii)*RHS
                conMAT%AL(ndof2*ik-iii) = 0.d0
              endif
              iii = iii - NDOF
            END DO
            exit
          endif
        enddo

      enddo
      !*End off - diagonal blocks

      call hecmw_cmat_ass_bc(hecMAT, inode, idof, RHS)

   end subroutine hecmw_mat_ass_bc

!C
!C***
!C*** MAT_ASS_CONTACT
!C***
!C
   subroutine hecmw_mat_ass_contact(hecMAT, nn, nodLOCAL, stiffness)
      type (hecmwST_matrix)     :: hecMAT
      integer(kind=kint) :: nn
      integer(kind=kint) :: nodLOCAL(:)
      real(kind=kreal) :: stiffness(:, :)
      !** Local variables
      integer(kind=kint) :: ndof, inod_e, jnod_e, inod, jnod
      real(kind=kreal) :: a(3,3)

      ndof = hecMAT%NDOF
      if( ndof .ne. 3 ) then
        write(*,*) '###ERROR### : ndof=',ndof,'; contact matrix supports only ndof==3'
        call hecmw_abort(hecmw_comm_get_comm())
        return
      endif

      do inod_e = 1, nn
        inod = nodLOCAL(inod_e)
        do jnod_e = 1, nn
          jnod = nodLOCAL(jnod_e)
          !***** Add components
          call stf_get_block(stiffness, ndof, inod_e, jnod_e, a)
          call hecmw_cmat_add(hecMAT%cmat, inod, jnod, a)
        enddo
      enddo
      call hecmw_cmat_pack(hecMAT%cmat)

   end subroutine hecmw_mat_ass_contact

end module hecmw_matrix_ass
