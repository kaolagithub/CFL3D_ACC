      subroutine resadd(jdim,kdim,idim,q,qc0,dqc0,res,vol,iover,blank)
      use info_x
      use fluid_x
      use unst_x
      use mgrd_x
c
c     $Id: resadd.F,v 1.2 2001/05/25 20:00:08 biedron Exp $
c
c***********************************************************************
c     Purpose:  Add additional terms to RHS for subiteration and 2nd
c     order temporal accuracy
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      dimension q(jdim,kdim,idim,5),qc0(jdim,kdim,idim-1,5),
     .          dqc0(jdim,kdim,idim-1,5),res(jdim,kdim,idim-1,5)
      dimension vol(jdim,kdim,idim-1),blank(jdim,kdim,idim)
c      common /info/ title(20),rkap(3),xmach,alpha,beta,dt,fmax,nit,ntt,
c     .        idiag(3),nitfo,iflagts,iflim(3),nres,levelb(5),mgflag,
c     .        iconsf,mseq,ncyc1(5),levelt(5),nitfo1(5),ngam,nsm(5),iipv
c      common /fluid/ gamma,gm1,gp1,gm1g,gp1g,ggm1
c      common /unst/ time,cfltau,ntstep,ita,iunst
c      common /mgrd/ levt,kode,mode,ncyc,mtt,icyc,level,lglobal
c
c     imult: multi-plane vectorization flag
c            = 0 single plane at a time
c            > 0 multiple planes at a time
c
      imult = 1
c
      idim1 = idim-1
      nt    = jdim*kdim
      nplq  = min(idim1,999000/nt)
      if (imult.eq.0) nplq = 1
      npl   = nplq
c 
      if (abs(ita) .eq. 1) then
        tfact=0.e0
      else
        tfact=0.5e0/dt
      end if
      tfacp1=tfact+1.e0/dt
c
      do 50 i=1,idim1,nplq
      if (i+npl-1.gt.idim1) npl = idim1-i+1
      n = nt*npl - jdim -1
c
c     ita=2 -- second order temporal differencing
c
      if (abs(ita).eq.2) then
cdir$ ivdep 
      do 10 izz=1,n 
c
      res(izz,1,i,1) = res(izz,1,i,1)
     . - tfact*vol(izz,1,i)*dqc0(izz,1,i,1)
c
      res(izz,1,i,2) = res(izz,1,i,2)
     . - tfact*vol(izz,1,i)*dqc0(izz,1,i,2)
c
      res(izz,1,i,3) = res(izz,1,i,3)
     . - tfact*vol(izz,1,i)*dqc0(izz,1,i,3)
c
      res(izz,1,i,4) = res(izz,1,i,4)
     . - tfact*vol(izz,1,i)*dqc0(izz,1,i,4)
c
      res(izz,1,i,5) = res(izz,1,i,5)
     . - tfact*vol(izz,1,i)*dqc0(izz,1,i,5)
10    continue
      end if
c
c     ncyc > 1 -- temporal subiteration
c
      if (ncyc.gt.1) then
cdir$ ivdep 
      do 20 izz=1,n 
c
      res(izz,1,i,1) = res(izz,1,i,1)+tfacp1*vol(izz,1,i)
     . *(q(izz,1,i,1)-qc0(izz,1,i,1))
c
      res(izz,1,i,2) = res(izz,1,i,2)+tfacp1*vol(izz,1,i)
     . *(q(izz,1,i,1)*q(izz,1,i,2)-qc0(izz,1,i,2))
c
      res(izz,1,i,3) = res(izz,1,i,3)+tfacp1*vol(izz,1,i)
     . *(q(izz,1,i,1)*q(izz,1,i,3)-qc0(izz,1,i,3))
c
      res(izz,1,i,4) = res(izz,1,i,4)+tfacp1*vol(izz,1,i)
     . *(q(izz,1,i,1)*q(izz,1,i,4)-qc0(izz,1,i,4))
c
      res(izz,1,i,5) = res(izz,1,i,5)+tfacp1*vol(izz,1,i)
     . *(q(izz,1,i,5)/gm1+0.5*q(izz,1,i,1)*(q(izz,1,i,2)**2
     . +q(izz,1,i,3)**2+q(izz,1,i,4)**2)-qc0(izz,1,i,5))
   20 continue
      end if
   50 continue    
c
c     zero out extra layers j=jdim and k=kdim for safety
c 
      do 500 i=1,idim1,nplq
      if (i+npl-1.gt.idim1) npl = idim1-i+1
      do 500 l=1,5
      do 600 ipl=1,npl
      ii = i+ipl-1
      do 700 j=1,jdim
      res(j,kdim,ii,l)  = 0.
  700 continue
cdir$ ivdep
      do 800 k=1,kdim-1
  800 res(jdim,k,ii,l)  = 0.
  600 continue
  500 continue
c
c     zero out rhs for fringe and hole cells
c
      if (iover.eq.1) then
c
         do 200 i=1,idim1,nplq
         if (i+npl-1.gt.idim1) npl = idim1-i+1
         call hole(i,npl,jdim,kdim,idim,res,blank)
  200    continue
      end if
c
      return
      end
