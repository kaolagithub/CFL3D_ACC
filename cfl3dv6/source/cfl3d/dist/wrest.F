      subroutine wrest(nbl,jdim,kdim,idim,q,qj0,qk0,qi0,ncycmax,rms,
     .                 clw,cdw,cdpw,cdvw,cxw,cyw,czw,cmxw,cmyw,cmzw,
     .                 fmdotw,cftmomw,cftpw,cftvw,cfttotw,rmstr1,
     .                 rmstr2,nneg1,nneg2,iskip,vist3d,tursav,
     .                 smin,xjb,xkb,blnum,cmuv,thetay,maxbl,
     .                 myid,myhost,mycomm,mblk2nd,igrid,wk,
     .                 idima,jdima,kdima,bcj,bck,bci,vj0,vk0,vi0,
     .                 tj0,tk0,ti0,blank,iwk,iwork,iover,
     .                 nou,bou,nbuf,ibufdim,qavg,x,y,z)
      use info_x
      use unst_x
      use reyue_x
      use conversion_x
      use maxiv_x
      use ghost_x
      use turbconv_x
      use cgns_x
      use degshf_x
      use fluid_x
      use fluid2_x
      use igrdtyp_x
      use ivals_x
      use twod_x
      use avgdata_x
c     $Id: wrest.F,v 1.11 2003/05/09 19:45:10 rumsey Exp $
c
c***********************************************************************
c     Purpose:  Write the restart file for a block. iskip = 1 means this
c               is the first block to be read in from the restart file;
c               all other blocks have iskip = 0
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
#if defined DIST_MPI
#     include "mpif.h"
#   ifdef DBLE_PRECSN
#      ifdef CMPLX
#        define MY_MPI_REAL MPI_DOUBLE_COMPLEX
#      else
#        define MY_MPI_REAL MPI_DOUBLE_PRECISION
#      endif
#   else
#      ifdef CMPLX
#        define MY_MPI_REAL MPI_COMPLEX
#      else
#        define MY_MPI_REAL MPI_REAL
#      endif
#   endif
      dimension istat(MPI_STATUS_SIZE)
#endif
c
      character*120 bou(ibufdim,nbuf)
c
      dimension nou(nbuf)
      dimension q(jdim,kdim,idim,5),qi0(jdim,kdim,5,4),
     .          qj0(kdim,idim-1,5,4), qk0(jdim,idim-1,5,4) 
      dimension rms(ncycmax),clw(ncycmax),cdw(ncycmax),cdpw(ncycmax),
     .          cdvw(ncycmax),cxw(ncycmax),cyw(ncycmax),czw(ncycmax),
     .          cmxw(ncycmax),cmyw(ncycmax),cmzw(ncycmax),
     .          fmdotw(ncycmax),cftmomw(ncycmax),cftpw(ncycmax),
     .          cftvw(ncycmax),cfttotw(ncycmax),
     .          rmstr1(ncycmax),rmstr2(ncycmax),nneg1(ncycmax),
     .          nneg2(ncycmax)
      dimension tursav(jdim,kdim,idim,2),vist3d(jdim,kdim,idim),
     .          smin(jdim-1,kdim-1,idim-1),xjb(jdim-1,kdim-1,idim-1),
     .          xkb(jdim-1,kdim-1,idim-1),blnum(jdim-1,kdim-1,idim-1),
     .          cmuv(jdim-1,kdim-1,idim-1)
      dimension thetay(maxbl),mblk2nd(maxbl)
      dimension qavg(jdim-1,kdim-1,idim-1,5),x(jdim,kdim,idim),
     .          y(jdim,kdim,idim),z(jdim,kdim,idim)
      dimension wk(idima+1,jdima+1,kdima+1)
      dimension bci(jdim,kdim,2),bcj(kdim,idim-1,2),bck(jdim,idim-1,2),
     .          vj0(kdim,idim-1,1,4),vk0(jdim,idim-1,1,4),
     .          vi0(jdim,kdim,1,4),tj0(kdim,idim-1,2,4),
     .          tk0(jdim,idim-1,2,4),ti0(jdim,kdim,2,4)
      dimension blank(jdim,kdim,idim),iwk(iwork)
c
c

c      common /info/ title(20),rkap(3),xmach,alpha,beta,dt,fmax,nit,ntt,
c     .        idiag(3),nitfo,iflagts,iflim(3),nres,levelb(5),mgflag,
c     .        iconsf,mseq,ncyc1(5),levelt(5),nitfo1(5),ngam,nsm(5),iipv
c      common /unst/ time,cfltau,ntstep,ita,iunst
c      common /reyue/ reue,tinf,ivisc(3)
c      common /conversion/ radtodeg
c      common /maxiv/ ivmx
c      common /ghost/ irghost,iwghost
c      common /turbconv/ cflturb,edvislim,iturbprod,nsubturb,nfreeze,
c     .                  iwarneddy,itime2read,itaturb,tur1cut
c      common /cgns/ icgns,iccg,ibase,nzones,nsoluse,irind,jrind,krind
c      common /degshf/ ideg(3)
c      common /fluid/ gamma,gm1,gp1,gm1g,gp1g,ggm1
c      common /fluid2/ pr,prt,cbar
c      common /igrdtyp/ ip3dgrd,ialph
c      common /ivals/ p0,rho0,c0,u0,v0,w0,et0,h0,pt0,rhot0,qiv(5),
c     .        tur10,tur20
c      common /twod/ i2d
c     common /avgdata/ xnumavg,iteravg
c
#if defined DIST_MPI
      nd_srce = mblk2nd(nbl)
c
c     set baseline tag values
c
      ioffset    = maxbl
      itag_q     = 1
      itag_qv    = itag_q     + ioffset
      itag_qt    = itag_qv    + ioffset
      itag_smin  = itag_qt    + ioffset
      itag_xjb   = itag_smin  + ioffset
      itag_xkb   = itag_xjb   + ioffset
      itag_blnum = itag_xkb   + ioffset
      itag_cmuv  = itag_blnum + ioffset
      itag_bci   = itag_cmuv  + ioffset
      itag_bcj   = itag_bci   + ioffset
      itag_bck   = itag_bcj   + ioffset
      itag_qi0   = itag_bck   + ioffset
      itag_qj0   = itag_qi0   + ioffset
      itag_qk0   = itag_qj0   + ioffset
      itag_blank = itag_qk0   + ioffset
      itag_vi0   = itag_blank + ioffset
      itag_vj0   = itag_vi0   + ioffset
      itag_vk0   = itag_vj0   + ioffset
      itag_ti0   = itag_vk0   + ioffset
      itag_tj0   = itag_ti0   + ioffset
      itag_tk0   = itag_tj0   + ioffset
      itag_qavg  = itag_tk0   + ioffset
c
      if (myid .eq. mblk2nd(nbl)) then
         mytag = nbl
         call MPI_Send(thetay(nbl),1,MY_MPI_REAL,
     .                 myhost,mytag,mycomm,ierr)
      else if (myid .eq. myhost) then
         mytag = nbl
         call MPI_Recv(thetay(nbl),1,MY_MPI_REAL,
     .                 nd_srce,mytag,mycomm,istat,ierr)
      end if
c
#endif
      alphw  = radtodeg*(alpha+thetay(nbl))
      betaw  = radtodeg*beta
      idim1 = idim-1
      jdim1 = jdim-1
      kdim1 = kdim-1
      jki   = jdim*kdim*idim
      jkim  = jdim1*kdim1*idim1
      jki2  = 2*jki
      jki5  = 5*jki
      jkim5 = jkim*5
      jk2   = jdim*kdim*2 
      ki2   = kdim*idim1*2 
      ji2   = jdim*idim1*2 
      jk20  = jdim*kdim*20
      ki20  = kdim*idim1*20
      ji20  = jdim*idim1*20
      jk4   = jdim*kdim*4
      ki4   = kdim*idim1*4
      ji4   = jdim*idim1*4
      jk8   = jdim*kdim*8
      ki8   = kdim*idim1*8
      ji8   = jdim*idim1*8
c
      if (myid.eq.myhost) then
      if (iskip.gt.0) then 
         write(11,6)nbl
      else
         write(11,7)nbl
      end if
    6 format(/,1x,30hwriting restart file for block,i5)
    7 format(1x,30hwriting restart file for block,i5)
      if (iskip.gt.0) then
        do n=1,ntt
          if(real(rmstr1(n)) .le. 0.) rmstr1(n)=1.
          if(real(rmstr2(n)) .le. 0.) rmstr2(n)=1.
        enddo
      end if
      if (icgns .ne. 1) then
      jt = jdim
      kt = kdim
      it = idim
c
      write(2) title,xmach,jt,kt,it,alphw,reue,ntt,time
c
      if (iskip.gt.0) then
         write(2) (rms(n),     n=1,ntt),(clw(n),     n=1,ntt),
     .            (cdw(n),     n=1,ntt),(cdpw(n),    n=1,ntt),
     .            (cdvw(n),    n=1,ntt),(cxw(n),     n=1,ntt),
     .            (cyw(n),     n=1,ntt),(czw(n),     n=1,ntt),
     .            (cmxw(n),    n=1,ntt),(cmyw(n),    n=1,ntt),
     .            (cmzw(n),    n=1,ntt),(fmdotw(n),  n=1,ntt),
     .            (cftmomw(n), n=1,ntt),(cftpw(n),   n=1,ntt),
     .            (cftvw(n),   n=1,ntt),(cfttotw(n), n=1,ntt)
      end if
      end if
      end if
c                                             
#if defined DIST_MPI
c
c.....send/receive solution (q = primitive variables) to/on
c.....the appropriate node and write to restart file
c
      if (myid .eq. mblk2nd(nbl)) then
         mytag = itag_q + nbl
         call MPI_Send(q,jki5,MY_MPI_REAL,
     .                 myhost,mytag,mycomm,ierr)
      else if (myid .eq. myhost) then
         mytag = itag_q + nbl
         call MPI_Recv(q,jki5,MY_MPI_REAL,
     .                 nd_srce,mytag,mycomm,istat,ierr)
      end if
      if (icgns .eq. 1) then
      if (myid .eq. mblk2nd(nbl)) then
         mytag = itag_bci + nbl
         call MPI_Send(bci,jk2,MY_MPI_REAL,
     .                 myhost,mytag,mycomm,ierr)
      else if (myid .eq. myhost) then
         mytag = itag_bci + nbl
         call MPI_Recv(bci,jk2,MY_MPI_REAL,
     .                 nd_srce,mytag,mycomm,istat,ierr)
      end if
c
      if (myid .eq. mblk2nd(nbl)) then
         mytag = itag_bcj + nbl
         call MPI_Send(bcj,ki2,MY_MPI_REAL,
     .                 myhost,mytag,mycomm,ierr)
      else if (myid .eq. myhost) then
         mytag = itag_bcj + nbl
         call MPI_Recv(bcj,ki2,MY_MPI_REAL,
     .                 nd_srce,mytag,mycomm,istat,ierr)
      end if
c
      if (myid .eq. mblk2nd(nbl)) then
         mytag = itag_bck + nbl
         call MPI_Send(bck,ji2,MY_MPI_REAL,
     .                 myhost,mytag,mycomm,ierr)
      else if (myid .eq. myhost) then
         mytag = itag_bck + nbl
         call MPI_Recv(bck,ji2,MY_MPI_REAL,
     .                 nd_srce,mytag,mycomm,istat,ierr)
      end if
      end if
c
      if (iwghost .ne. 0) then
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_qi0 + nbl
            call MPI_Send(qi0,jk20,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_qi0 + nbl
            call MPI_Recv(qi0,jk20,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_qj0 + nbl
            call MPI_Send(qj0,ki20,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_qj0 + nbl
            call MPI_Recv(qj0,ki20,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_qk0 + nbl
            call MPI_Send(qk0,ji20,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_qk0 + nbl
            call MPI_Recv(qk0,ji20,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
      end if
      if ((icgns .eq. 1 .and. iover .eq. 1) .or. 
     .    (iteravg .eq. 1 .or. iteravg .eq. 2)) then
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_blank + nbl
            call MPI_Send(blank,jki,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_blank + nbl
            call MPI_Recv(blank,jki,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
      end if
c
#endif
c
      if (myid.eq.myhost) then
      if (icgns .ne. 1) then
         write(2) ((((q(j,k,i,l),j=1,jdim1),k=1,kdim1),i=1,idim1),l=1,5)
         if (iwghost .ne. 0)
     .   write(2) ((((qi0(j,k,l,m),j=1,jdim1),k=1,kdim1),l=1,5),m=1,4),
     .            ((((qj0(k,i,l,m),k=1,kdim1),i=1,idim1),l=1,5),m=1,4),
     .            ((((qk0(j,i,l,m),j=1,jdim1),i=1,idim1),l=1,5),m=1,4)
      else
#if defined CGNS
      write(11,'('' cgns write in wrest'')')
      if (iwghost .ne. 0) then
        write(11,'('' cgns writing specific BC values (primitive)'')')
        call writebcs(iccg,ibase,igrid,idim,jdim,kdim,qj0,qk0,qi0,
     +    vj0,vk0,vi0,tj0,tk0,ti0,i2d)
      else
c       need to delete CFL3DBoundaryValues node if it exists
        call cg_goto_f(iccg,ibase,ier,'Zone_t',igrid,'end')
        call cg_delete_node_f('CFL3DBoundaryValues',ier)
      end if
      write(11,'(''  ...writing conserved q variables'')')
c     translate to conserved (for CGNS output only)
      do i=1,idim1
        do k=1,kdim1
        do j=1,jdim1
          q(j,k,i,2)=q(j,k,i,2)*q(j,k,i,1)
          q(j,k,i,3)=q(j,k,i,3)*q(j,k,i,1)
          q(j,k,i,4)=q(j,k,i,4)*q(j,k,i,1)
          q(j,k,i,5)=q(j,k,i,5)/gm1+0.5/q(j,k,i,1)*(q(j,k,i,2)**2+
     +               q(j,k,i,3)**2+q(j,k,i,4)**2)
        enddo
        enddo
        do m=1,3,2
        do k=1,kdim1
          qj0(k,i,2,m)=qj0(k,i,2,m)*qj0(k,i,1,m)
          qj0(k,i,3,m)=qj0(k,i,3,m)*qj0(k,i,1,m)
          qj0(k,i,4,m)=qj0(k,i,4,m)*qj0(k,i,1,m)
          qj0(k,i,5,m)=qj0(k,i,5,m)/gm1+0.5/qj0(k,i,1,m)*
     +      (qj0(k,i,2,m)**2+qj0(k,i,3,m)**2+qj0(k,i,4,m)**2)
        enddo
        do j=1,jdim1
          qk0(j,i,2,m)=qk0(j,i,2,m)*qk0(j,i,1,m)
          qk0(j,i,3,m)=qk0(j,i,3,m)*qk0(j,i,1,m)
          qk0(j,i,4,m)=qk0(j,i,4,m)*qk0(j,i,1,m)
          qk0(j,i,5,m)=qk0(j,i,5,m)/gm1+0.5/qk0(j,i,1,m)*
     +      (qk0(j,i,2,m)**2+qk0(j,i,3,m)**2+qk0(j,i,4,m)**2)
        enddo
        enddo
      enddo
      do m=1,3,2
      do k=1,kdim1
        do j=1,jdim1
          qi0(j,k,2,m)=qi0(j,k,2,m)*qi0(j,k,1,m)
          qi0(j,k,3,m)=qi0(j,k,3,m)*qi0(j,k,1,m)
          qi0(j,k,4,m)=qi0(j,k,4,m)*qi0(j,k,1,m)
          qi0(j,k,5,m)=qi0(j,k,5,m)/gm1+0.5/qi0(j,k,1,m)*
     +      (qi0(j,k,2,m)**2+qi0(j,k,3,m)**2+qi0(j,k,4,m)**2)
        enddo
      enddo
      enddo
      call writesoln(iccg,ibase,igrid,idima,jdima,kdima,idim,
     +  jdim,kdim,wk,q,qj0,qk0,qi0,bcj,bck,bci,i2d,ialph,nsoluse)
c     translate back to primitive (so don't mess anything up that may come later)
      do i=1,idim1
        do k=1,kdim1
        do j=1,jdim1
          q(j,k,i,2)=q(j,k,i,2)/q(j,k,i,1)
          q(j,k,i,3)=q(j,k,i,3)/q(j,k,i,1)
          q(j,k,i,4)=q(j,k,i,4)/q(j,k,i,1)
          q(j,k,i,5)=gm1*(q(j,k,i,5)-0.5*q(j,k,i,1)*(q(j,k,i,2)**2+
     +               q(j,k,i,3)**2+q(j,k,i,4)**2))
        enddo
        enddo
        do m=1,3,2
        do k=1,kdim1
          qj0(k,i,2,m)=qj0(k,i,2,m)/qj0(k,i,1,m)
          qj0(k,i,3,m)=qj0(k,i,3,m)/qj0(k,i,1,m)
          qj0(k,i,4,m)=qj0(k,i,4,m)/qj0(k,i,1,m)
          qj0(k,i,5,m)=gm1*(qj0(k,i,5,m)-0.5*qj0(k,i,1,m)*
     +      (qj0(k,i,2,m)**2+qj0(k,i,3,m)**2+qj0(k,i,4,m)**2))
        enddo
        do j=1,jdim1
          qk0(j,i,2,m)=qk0(j,i,2,m)/qk0(j,i,1,m)
          qk0(j,i,3,m)=qk0(j,i,3,m)/qk0(j,i,1,m)
          qk0(j,i,4,m)=qk0(j,i,4,m)/qk0(j,i,1,m)
          qk0(j,i,5,m)=gm1*(qk0(j,i,5,m)-0.5*qk0(j,i,1,m)*
     +      (qk0(j,i,2,m)**2+qk0(j,i,3,m)**2+qk0(j,i,4,m)**2))
        enddo
        enddo
      enddo
      do m=1,3,2
      do k=1,kdim1
        do j=1,jdim1
          qi0(j,k,2,m)=qi0(j,k,2,m)/qi0(j,k,1,m)
          qi0(j,k,3,m)=qi0(j,k,3,m)/qi0(j,k,1,m)
          qi0(j,k,4,m)=qi0(j,k,4,m)/qi0(j,k,1,m)
          qi0(j,k,5,m)=gm1*(qi0(j,k,5,m)-0.5*qi0(j,k,1,m)*
     +      (qi0(j,k,2,m)**2+qi0(j,k,3,m)**2+qi0(j,k,4,m)**2))
        enddo
      enddo
      enddo
c     write overset holes
      if (iover .eq. 1) then
c     first, find out how many holes
        n=0
        do k=1,kdim-1
        do j=1,jdim-1
        do i=1,idim-1
          if(blank(j,k,i) .eq. 0.) then
            n=n+1
          end if
        enddo
        enddo
        enddo
        npnts=n
        if (npnts .gt. 0) then
        if (iwork .lt. npnts*3) then
          write(11,'('' not enough memory for cgns blank'',
     +      '' write.'')')
          write(11,'('' iwork in iwk='',i6,''.  Needed = '',i6)')
     +      iwork,npnts*3
          call termn8(myid,-1,ibufdim,nbuf,bou,nou)
        end if
        call writeblnk(iccg,ibase,igrid,idim,jdim,kdim,npnts,iwk,
     .                     blank)
        end if
      end if
      call writeziter(iccg,ibase,igrid)
      if (iskip .gt. 0) then
        call writehist(iccg,ibase,ntt,rms,clw,cdw,cdpw,cdvw,cxw,
     +   cyw,czw,cmxw,cmyw,cmzw,fmdotw,cftmomw,cftpw,cftvw,
     +   cfttotw,rmstr1,rmstr2,nneg1,nneg2)
        vkk0=1.
        xlength0=1.
        call writeref(iccg,ibase,xmach,reue,
     +   rho0,c0,p0,vkk0,xlength0,tinf,alphw,betaw,
     +   u0,v0,w0,ialph)
        call writetime(iccg,ibase,time,ntt,dt)
      end if
#endif
      end if
c
c     turbulence quantities
c
      if (icgns .ne. 1) then
      write(2) ivisc(1),ivisc(2),ivisc(3)
c
      if (iskip.gt.0) then
          write(2) (rmstr1(n),n=1,ntt),(rmstr2(n),n=1,ntt),
     .             (nneg1(n), n=1,ntt),(nneg2(n), n=1,ntt)
      end if
      end if
      end if
c
      if (ivisc(1).ge.2 .or. ivisc(2).ge.2 .or. ivisc(3).ge.2) then
#if defined DIST_MPI
c
c........eddy viscosity
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_qv + nbl
            call MPI_Send(vist3d,jki,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_qv + nbl
            call MPI_Recv(vist3d,jki,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
         if (iwghost .ne. 0) then
            if (myid .eq. mblk2nd(nbl)) then
               mytag = itag_vi0 + nbl
               call MPI_Send(vi0,jk4,MY_MPI_REAL,
     .                       myhost,mytag,mycomm,ierr)
            else if (myid .eq. myhost) then
               mytag = itag_vi0 + nbl
               call MPI_Recv(vi0,jk4,MY_MPI_REAL,
     .                       nd_srce,mytag,mycomm,istat,ierr)
            end if
c
            if (myid .eq. mblk2nd(nbl)) then
               mytag = itag_vj0 + nbl
               call MPI_Send(vj0,ki4,MY_MPI_REAL,
     .                       myhost,mytag,mycomm,ierr)
            else if (myid .eq. myhost) then
               mytag = itag_vj0 + nbl
               call MPI_Recv(vj0,ki4,MY_MPI_REAL,
     .                       nd_srce,mytag,mycomm,istat,ierr)
            end if
c
            if (myid .eq. mblk2nd(nbl)) then
               mytag = itag_vk0 + nbl
               call MPI_Send(vk0,ji4,MY_MPI_REAL,
     .                       myhost,mytag,mycomm,ierr)
            else if (myid .eq. myhost) then
               mytag = itag_vk0 + nbl
               call MPI_Recv(vk0,ji4,MY_MPI_REAL,
     .                       nd_srce,mytag,mycomm,istat,ierr)
            end if
         end if
#endif
c
         if (myid .eq. myhost) then
c
c           check to see if eddy viscosity has been limited
c
            if (iwarneddy .ne. -1 ) then
               do j=1,jdim1
                  do k=1,kdim1
                     do i=1,idim1
                        if (real(vist3d(j,k,i)).eq.real(edvislim)) then
                           iwarneddy = 1
                        end if
                     end do
                  end do
               end do
            end if
         if (icgns .ne. 1) then
         write(11,'(''   writing vist3d data to restart file'',
     .   '', block'',i5)') nbl
         write(2) (((vist3d(j,k,i),j=1,jdim1),k=1,kdim1),i=1,idim1)
         if (iwghost .ne. 0)
     .   write(2) ((((vi0(j,k,l,m),j=1,jdim),k=1,kdim),l=1,1),m=1,4),
     .            ((((vj0(k,i,l,m),k=1,kdim),i=1,idim1),l=1,1),m=1,4),
     .            ((((vk0(j,i,l,m),j=1,jdim),i=1,idim1),l=1,1),m=1,4)
         end if
         end if
      end if
c
      if (ivisc(1).ge.4 .or. ivisc(2).ge.4 .or. ivisc(3).ge.4) then
c
c........turbulence quantities (e.g. k and omega)
c
#if defined DIST_MPI
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_qt + nbl
            call MPI_Send(tursav,jki2,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_qt + nbl
            call MPI_Recv(tursav,jki2,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
         if (iwghost .ne. 0) then
            if (myid .eq. mblk2nd(nbl)) then
               mytag = itag_ti0 + nbl
               call MPI_Send(ti0,jk8,MY_MPI_REAL,
     .                       myhost,mytag,mycomm,ierr)
            else if (myid .eq. myhost) then
               mytag = itag_ti0 + nbl
               call MPI_Recv(ti0,jk8,MY_MPI_REAL,
     .                       nd_srce,mytag,mycomm,istat,ierr)
            end if
c
            if (myid .eq. mblk2nd(nbl)) then
               mytag = itag_tj0 + nbl
               call MPI_Send(tj0,ki8,MY_MPI_REAL,
     .                       myhost,mytag,mycomm,ierr)
            else if (myid .eq. myhost) then
               mytag = itag_tj0 + nbl
               call MPI_Recv(tj0,ki8,MY_MPI_REAL,
     .                       nd_srce,mytag,mycomm,istat,ierr)
            end if
c
            if (myid .eq. mblk2nd(nbl)) then
               mytag = itag_tk0 + nbl
               call MPI_Send(tk0,ji8,MY_MPI_REAL,
     .                       myhost,mytag,mycomm,ierr)
            else if (myid .eq. myhost) then
               mytag = itag_tk0 + nbl
               call MPI_Recv(tk0,ji8,MY_MPI_REAL,
     .                       nd_srce,mytag,mycomm,istat,ierr)
            end if
         end if
c
#endif
c
         if (myid .eq. myhost) then
         if (icgns .ne. 1) then
         write(11,'(''   writing field eqn turb quantities'',
     .              '' to restart file'',
     .              '', block'',i5)') nbl
         write(2) ((((tursav(j,k,i,m),j=1,jdim1),k=1,kdim1),i=1,idim1),
     .            m=1,2)
         if (iwghost .ne. 0)
     .   write(2) ((((ti0(j,k,l,m),j=1,jdim),k=1,kdim),l=1,2),m=1,4),
     .            ((((tj0(k,i,l,m),k=1,kdim),i=1,idim1),l=1,2),m=1,4),
     .            ((((tk0(j,i,l,m),j=1,jdim),i=1,idim1),l=1,2),m=1,4)
         end if
         end if
c
c........minimum distance function
c
#if defined DIST_MPI
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_smin + nbl
            call MPI_Send(smin,jkim,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_smin + nbl
            call MPI_Recv(smin,jkim,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
#endif
c
         if (myid .eq. myhost) then
         do i=1,idim1
         do j=1,jdim1
         do k=1,kdim1
           smin(j,k,i)=ccabs(smin(j,k,i))
         enddo
         enddo
         enddo
         if (icgns .ne. 1) then
         write(2) (((smin(j,k,i),j=1,jdim1),k=1,kdim1),i=1,idim1)
         end if
         end if
c
      end if
c

         if (ivisc(1).eq.4 .or. ivisc(2).eq.4 .or. ivisc(3).eq.4) then
c
c........additional smin-related data for baldwin-barth
c
#if defined DIST_MPI
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_xjb + nbl
            call MPI_Send(xjb,jkim,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_xjb + nbl
            call MPI_Recv(xjb,jkim,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
#endif
c
         if (myid .eq. myhost) then
         if (icgns .ne. 1) then
            write(2) (((xjb(j,k,i),j=1,jdim-1),k=1,kdim-1),i=1,idim-1)
         end if
         end if
c
#if defined DIST_MPI
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_xkb + nbl
            call MPI_Send(xkb,jkim,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_xkb + nbl
            call MPI_Recv(xkb,jkim,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
#endif
c
         if (myid .eq. myhost) then
         if (icgns .ne. 1) then
            write(2) (((xkb(j,k,i),j=1,jdim-1),k=1,kdim-1),i=1,idim-1)
         end if
         end if
c
#if defined DIST_MPI
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_blnum + nbl
            call MPI_Send(blnum,jkim,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_blnum + nbl
            call MPI_Recv(blnum,jkim,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
#endif
c
         if (myid .eq. myhost) then
         if (icgns .ne. 1) then
            write(2) (((blnum(j,k,i),j=1,jdim-1),k=1,kdim-1),i=1,idim-1)
         end if
         end if
         end if
         if (ivisc(1).eq.8 .or. ivisc(2).eq.8 .or. ivisc(3).eq.8  .or.
     .       ivisc(1).eq.9 .or. ivisc(2).eq.9 .or. ivisc(3).eq.9  .or.
     .       ivisc(1).eq.13.or. ivisc(2).eq.13.or. ivisc(3).eq.13 .or.
     .       ivisc(1).eq.14.or. ivisc(2).eq.14.or. ivisc(3).eq.14) then
c
#if defined DIST_MPI
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_cmuv + nbl
            call MPI_Send(cmuv,jkim,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_cmuv + nbl
            call MPI_Recv(cmuv,jkim,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
#endif
c
         if (myid .eq. myhost) then
         if (icgns .ne. 1) then
            write(2) (((cmuv(j,k,i),j=1,jdim-1),k=1,kdim-1),i=1,idim-1)
         end if
         end if
         end if
      if (icgns .eq. 1 .and. myid .eq. myhost) then
#if defined CGNS
        call writeeqn(iccg,ibase,igrid,ivisc(1),ivisc(2),ivisc(3),ideg,
     +   gamma,pr,prt,cbar)
        call writeturb(iccg,ibase,igrid,nsoluse,idima,jdima,kdima,
     +   idim,jdim,kdim,ivisc,wk,vist3d,tursav,smin,xjb,xkb,
     +   tursav(1,1,1,2),blnum,cmuv,vj0,vk0,vi0,tj0,tk0,ti0,i2d,
     +   xmach,reue)
#endif
      end if
      if (iteravg .eq. 1 .or. iteravg .eq. 2) then
c
#if defined DIST_MPI
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_cmuv + nbl
            call MPI_Send(x,jki,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_cmuv + nbl
            call MPI_Recv(x,jki,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_cmuv + nbl
            call MPI_Send(y,jki,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_cmuv + nbl
            call MPI_Recv(y,jki,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_cmuv + nbl
            call MPI_Send(z,jki,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_cmuv + nbl
            call MPI_Recv(z,jki,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
         if (myid .eq. mblk2nd(nbl)) then
            mytag = itag_qavg + nbl
            call MPI_Send(qavg,jkim5,MY_MPI_REAL,
     .                    myhost,mytag,mycomm,ierr)
         else if (myid .eq. myhost) then
            mytag = itag_qavg + nbl
            call MPI_Recv(qavg,jkim5,MY_MPI_REAL,
     .                    nd_srce,mytag,mycomm,istat,ierr)
         end if
c
#endif
c
c   write cell-centered plot3d files of current grid and averaged q's
        if (myid .eq. myhost) then
        if (ialph .eq. 0) then
        write(96)   (((0.125*(x(j  ,k  ,i  )+x(j+1,k  ,i  )+
     +                        x(j  ,k+1,i  )+x(j  ,k  ,i+1)+
     +                        x(j+1,k+1,i  )+x(j+1,k  ,i+1)+
     +                        x(j  ,k+1,i+1)+x(j+1,k+1,i+1)),
     +                        i=1,idim-1),j=1,jdim-1),k=1,kdim-1),
     +              (((0.125*(y(j  ,k  ,i  )+y(j+1,k  ,i  )+
     +                        y(j  ,k+1,i  )+y(j  ,k  ,i+1)+
     +                        y(j+1,k+1,i  )+y(j+1,k  ,i+1)+
     +                        y(j  ,k+1,i+1)+y(j+1,k+1,i+1)),
     +                        i=1,idim-1),j=1,jdim-1),k=1,kdim-1),
     +              (((0.125*(z(j  ,k  ,i  )+z(j+1,k  ,i  )+
     +                        z(j  ,k+1,i  )+z(j  ,k  ,i+1)+
     +                        z(j+1,k+1,i  )+z(j+1,k  ,i+1)+
     +                        z(j  ,k+1,i+1)+z(j+1,k+1,i+1)),
     +                        i=1,idim-1),j=1,jdim-1),k=1,kdim-1),
     +              (((int(blank(j,k,i)),
     +                        i=1,idim-1),j=1,jdim-1),k=1,kdim-1)
        else
        write(96)   (((0.125*(x(j  ,k  ,i  )+x(j+1,k  ,i  )+
     +                        x(j  ,k+1,i  )+x(j  ,k  ,i+1)+
     +                        x(j+1,k+1,i  )+x(j+1,k  ,i+1)+
     +                        x(j  ,k+1,i+1)+x(j+1,k+1,i+1)),
     +                        i=1,idim-1),j=1,jdim-1),k=1,kdim-1),
     +              (((0.125*(z(j  ,k  ,i  )+z(j+1,k  ,i  )+
     +                        z(j  ,k+1,i  )+z(j  ,k  ,i+1)+
     +                        z(j+1,k+1,i  )+z(j+1,k  ,i+1)+
     +                        z(j  ,k+1,i+1)+z(j+1,k+1,i+1)),
     +                        i=1,idim-1),j=1,jdim-1),k=1,kdim-1),
     +              (((-0.125*(y(j  ,k  ,i  )+y(j+1,k  ,i  )+
     +                        y(j  ,k+1,i  )+y(j  ,k  ,i+1)+
     +                        y(j+1,k+1,i  )+y(j+1,k  ,i+1)+
     +                        y(j  ,k+1,i+1)+y(j+1,k+1,i+1)),
     +                        i=1,idim-1),j=1,jdim-1),k=1,kdim-1),
     +              (((int(blank(j,k,i)),
     +                        i=1,idim-1),j=1,jdim-1),k=1,kdim-1)
        end if
c   need to switch y and z if ialph .ne. 0
        if (ialph .ne. 0) then
          do i=1,idim-1
            do j=1,jdim-1
              do k=1,kdim-1
                temp=qavg(j,k,i,3)
                qavg(j,k,i,3)=qavg(j,k,i,4)
                qavg(j,k,i,4)=-temp
              enddo
            enddo
          enddo
        end if
c   xnumavg is used to store the number of averaged iterations so far
        write(97) xmach,alpha,reue,xnumavg
        write(97) ((((qavg(j,k,i,m),i=1,idim-1),j=1,jdim-1),
     +    k=1,kdim-1),m=1,5) 
        end if
      end if
c
      return
      end
