      subroutine tau(mgflag,nbl,jdim,kdim,idim,q,res,q1,qr,lw,w,
     .               nou,bou,nbuf,ibufdim,maxbl,maxgr,nblock,igridg,
     .               nblcg,jsg,ksg,isg,jeg,keg,ieg,iemg)
      use mgrd_x
      use sklton_x
c
c     $Id: tau.F,v 1.2 2001/05/25 20:00:09 biedron Exp $
c
c***********************************************************************
c     Purpose:  Compute a residual correction and store the values of
c     q for later use in determining corrections to finer grids in the
c     multigrid iteration scheme.
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      character*120 bou(ibufdim,nbuf)
c
      dimension nou(nbuf)
      dimension w(1)
      dimension lw(65,maxbl)
      dimension res(jdim*kdim*(idim-1),5)
      dimension q(jdim*kdim*idim,5)
      dimension q1(jdim*kdim*idim,5),qr(jdim*kdim*(idim-1),5),
     .          igridg(maxbl),nblcg(maxbl),jsg(maxbl),ksg(maxbl),
     .          isg(maxbl),jeg(maxbl),keg(maxbl),ieg(maxbl),iemg(maxgr)
c
c      common /mgrd/ levt,kode,mode,ncyc,mtt,icyc,level,lglobal
c      common /sklton/ isklton
c
c     store q1 for later use in determining delta q
c     residual correction
c
      jdim1 = jdim-1
      kdim1 = kdim-1
      idim1 = idim-1
c
      if (kode.ge.2 .and. mgflag.ge.1) then
      if (level.ge.lglobal .and. mgflag.lt.2) go to 1001
c
c     store q1=q   kode.ge.2
c
      n    = jdim*kdim
      nplq = min(idim1,999000/n)
      npl  = nplq
      do 5 i=1,idim1,nplq
      if (i+npl-1.gt.idim1) npl = idim1-i+1
      nnpl = n*npl-jdim-1
      ist  = (i-1)*n
      do 5 l=1,5
cdir$ ivdep
      do 5 izz=1,nnpl
      q1(izz+ist,l) = q(izz+ist,l)
    5 continue
      end if
 1001 continue
c
      if (mode.ne.0) then
c
c      qr=qr-res       mode.ne.0    kode.ge.2
c
c      res=res+qr      mode.ne.0
c
      if (level.lt.lglobal) then
c
      if (isklton.gt.0) then
         nou(1) = min(nou(1)+1,ibufdim)
         write(bou(nou(1),1),*)
         nou(1) = min(nou(1)+1,ibufdim)
         write(bou(nou(1),1),8) nbl,nbl-1,kode
      end if
    8 format(1x,36hadding residual correction for block,i3,
     .       1x,16hfrom finer block,i3,7h; kode=,i3)
c
c     residual correction from global grids
c
      n    = jdim*kdim
      nplq = min(idim1,999000/n)
      npl  = nplq
      do 45 i=1,idim1,nplq
      if (i+npl-1.gt.idim1) npl = idim1-i+1
      nnpl = n*npl-jdim-1
      ist  = (i-1)*n
      if (kode.ge.2) then
         do 42 l=1,5
cdir$ ivdep
         do 42 izz=1,nnpl
         qr(izz+ist,l) = qr(izz+ist,l)-res(izz+ist,l)
   42    continue
      end if
c
      do 44 l=1,5
cdir$ ivdep
      do 44 izz=1,nnpl
      res(izz+ist,l) = res(izz+ist,l)+qr(izz+ist,l)
   44 continue
   45 continue
c
      else
c
c      residual correction from embedded grids
c
      do 9638 nblc=1,nblock
      igrid = igridg(nblc)
      if (nblc.eq.nbl .or. iemg(igrid).eq.0) go to 9638
c
      nblcc   = nblcg(nblc)
      if (nblcc.eq.nbl) then
         jsc  = jsg(nblc)
         ksc  = ksg(nblc)
         isc  = isg(nblc)
         jec  = jeg(nblc)
         kec  = keg(nblc)
         iec  = ieg(nblc)
         lqrc = lw(17,nblc)
c
         if (isklton.gt.0) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),*)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),18) nbl,nblc,kode
         end if
c
         call tau2x(jdim,kdim,idim,res,w(lqrc),jsc,ksc,isc,jec,kec,iec,
     .              kode)
      end if
   18 format(1x,36hadding residual correction for block,i3,
     .       1x,19hfrom embedded block,i3,7h; kode=,i3)
 9638 continue
      end if
      end if
      return
      end
