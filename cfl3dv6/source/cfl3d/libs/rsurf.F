      subroutine rsurf(maxbl,maxsegdg,idim,jdim,kdim,delti,deltj,deltk,
     .                 nbl,icsi,icsf,jcsi,jcsf,kcsi,kcsf,iseg,nou,bou,
     .                 nbuf,ibufdim,iunit)
      use igrdtyp_x
      use mydist2_x
      use complx_x
c
c     $Id: rsurf.F,v 1.4 2002/02/20 21:51:39 biedron Exp $
c
c***********************************************************************
c     Purpose:  Read in a new surface grid and store in the 
c     deltj/deltk,delti arrays.
c
c     Note: it is assumed the surface data is in plot3d format, e.g.
c     the x-coordinate was written out as :
c
c     write() (((x(),i=i1,i2),j=j1,j2),k=k1,k2)
c
c     Furthermore, it is assumed that the ialph parameter (which 
c     governs wheter y or z is "up") is the same for both the original
c     grid and the new surface grid.
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
c
      integer stats
c
      real, dimension(:,:,:,:), allocatable :: deltir
      real, dimension(:,:,:,:), allocatable :: deltjr
      real, dimension(:,:,:,:), allocatable :: deltkr
c
#   endif
c
      character*120 bou(ibufdim,nbuf)
c
      dimension nou(nbuf)
      dimension deltj(kdim,idim,3,2),deltk(jdim,idim,3,2),
     .          delti(jdim,kdim,3,2)
      dimension icsi(maxbl,maxsegdg),icsf(maxbl,maxsegdg),
     .          jcsi(maxbl,maxsegdg),jcsf(maxbl,maxsegdg),
     .          kcsi(maxbl,maxsegdg),kcsf(maxbl,maxsegdg)
c
c      common /igrdtyp/ ip3dgrd,ialph
c      common /mydist2/ nnodes,myhost,myid,mycomm
c      common /complx/ xmach_img,alpha_img,beta_img,reue_img,tinf_img,
c     .                geom_img,surf_img,xrotrate_img,yrotrate_img,
c     .                zrotrate_img
c
      isurf_img = 0
c
#ifdef CMPLX
c     allocate real arrays in which to read surface grid data
c     (for non-geometric derivatives)
c
      memuse = 0
      allocate( deltir(jdim,kdim,3,2), stat=stats )
      call umalloc(jdim*kdim*3*2,0,'deltir',memuse,stats)
      allocate( deltjr(kdim,idim,3,2), stat=stats )
      call umalloc(kdim*idim*3*2,0,'deltjr',memuse,stats)
      allocate( deltkr(jdim,idim,3,2), stat=stats )
      call umalloc(jdim*idim*3*2,0,'deltkr',memuse,stats)
c
c     flag to read complex-valued grid
c
      if (real(surf_img).gt.0.) then
         isurf_img = 1
      end if

#endif
c
      is = icsi(nbl,iseg)
      ie = icsf(nbl,iseg)
      js = jcsi(nbl,iseg)
      je = jcsf(nbl,iseg)
      ks = kcsi(nbl,iseg)
      ke = kcsf(nbl,iseg)
      if (is .eq. ie) then
          mm = 1
          if (is .eq. idim) mm = 2
#ifdef CMPLX
          if (isurf_img .eq. 0) then
c
c            for non-geometric derivatives, input surface grid is real
c
             read(iunit,*)((deltir(j,k,1,mm),j=js,je),k=ks,ke),
     .                    ((deltir(j,k,2,mm),j=js,je),k=ks,ke),
     .                    ((deltir(j,k,3,mm),j=js,je),k=ks,ke)
             do k=ks,ke
                do j=js,je
                   delti(j,k,1,mm) = deltir(j,k,1,mm)
                   delti(j,k,2,mm) = deltir(j,k,2,mm)
                   delti(j,k,3,mm) = deltir(j,k,3,mm)
                end do
             end do
          else
c
c            for geometric derivatives, input surface grid is complex
c
             read(iunit,*)((delti(j,k,1,mm),j=js,je),k=ks,ke),
     .                    ((delti(j,k,2,mm),j=js,je),k=ks,ke),
     .                    ((delti(j,k,3,mm),j=js,je),k=ks,ke) 
          end if

#else
          read(iunit,*)((delti(j,k,1,mm),j=js,je),k=ks,ke),
     .                 ((delti(j,k,2,mm),j=js,je),k=ks,ke),
     .                 ((delti(j,k,3,mm),j=js,je),k=ks,ke) 
#endif
          if (ialph .ne. 0) then
             do k=ks,ke
                do j=js,je
                   temp            = delti(j,k,3,mm)
                   delti(j,k,3,mm) = delti(j,k,2,mm)
                   delti(j,k,2,mm) = -temp
                end do
             end do
          end if 
      else if (js .eq. je) then
          mm = 1
          if (js .eq. jdim) mm = 2
#ifdef CMPLX
          if (isurf_img .eq. 0) then
c
c            for non-geometric derivatives, input surface grid is real
c
             read(iunit,*)((deltjr(k,i,1,mm),i=is,ie),k=ks,ke),
     .                    ((deltjr(k,i,2,mm),i=is,ie),k=ks,ke),
     .                    ((deltjr(k,i,3,mm),i=is,ie),k=ks,ke)
             do i=is,ie
                do k=ks,ke
                   deltj(k,i,1,mm) = deltjr(k,i,1,mm)
                   deltj(k,i,2,mm) = deltjr(k,i,2,mm)
                   deltj(k,i,3,mm) = deltjr(k,i,3,mm)
                end do
             end do
          else
c
c            for geometric derivatives, input surface grid is complex
c
             read(iunit,*)((deltj(k,i,1,mm),i=is,ie),k=ks,ke),
     .                    ((deltj(k,i,2,mm),i=is,ie),k=ks,ke),
     .                    ((deltj(k,i,3,mm),i=is,ie),k=ks,ke)

          end if
#else
          read(iunit,*)((deltj(k,i,1,mm),i=is,ie),k=ks,ke),
     .                 ((deltj(k,i,2,mm),i=is,ie),k=ks,ke),
     .                 ((deltj(k,i,3,mm),i=is,ie),k=ks,ke)
#endif
          if (ialph .ne. 0) then
             do i=is,ie
                do k=ks,ke
                   temp            = deltj(k,i,3,mm)
                   deltj(k,i,3,mm) = deltj(k,i,2,mm)
                   deltj(k,i,2,mm) = -temp
                end do
             end do
          end if
      else if (ks .eq. ke) then
          mm = 1
          if (ks .eq. kdim) mm = 2
#ifdef CMPLX
          if (isurf_img .eq. 0) then
c
c            for non-geometric derivatives, input surface grid is real
c
             read(iunit,*)((deltkr(j,i,1,mm),i=is,ie),j=js,je),
     .                    ((deltkr(j,i,2,mm),i=is,ie),j=js,je),
     .                    ((deltkr(j,i,3,mm),i=is,ie),j=js,je)
             do i=is,ie
                do j=js,je
                   deltk(j,i,1,mm) = deltkr(j,i,1,mm)
                   deltk(j,i,2,mm) = deltkr(j,i,2,mm)
                   deltk(j,i,3,mm) = deltkr(j,i,3,mm)
                end do
             end do
          else
c
c            for geometric derivatives, input surface grid is complex
c
             read(iunit,*)((deltk(j,i,1,mm),i=is,ie),j=js,je),
     .                    ((deltk(j,i,2,mm),i=is,ie),j=js,je),
     .                    ((deltk(j,i,3,mm),i=is,ie),j=js,je)
          end if
#else
          read(iunit,*)((deltk(j,i,1,mm),i=is,ie),j=js,je),
     .                 ((deltk(j,i,2,mm),i=is,ie),j=js,je),
     .                 ((deltk(j,i,3,mm),i=is,ie),j=js,je)
#endif
          if (ialph .ne. 0) then
             do i=is,ie
                do j=js,je
                   temp            = deltk(j,i,3,mm)
                   deltk(j,i,3,mm) = deltk(j,i,2,mm)
                   deltk(j,i,2,mm) = -temp
                end do
             end do
          end if
      else
          nou(1) = min(nou(1)+1,ibufdim)
          write(bou(nou(1),1),'('' error in rsurf...one surface'',
     .    '' dimension must be 1'')')
          call termn8(myid,-1,ibufdim,nbuf,bou,nou)
      end if
#   ifdef CMPLX
c
c     deallocate real arrays in which surface data was read
c
      deallocate(deltjr)
      deallocate(deltkr)
      deallocate(deltir)
#   endif
c
      return
      end
