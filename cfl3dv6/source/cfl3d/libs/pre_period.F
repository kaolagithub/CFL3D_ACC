      subroutine pre_period(nbl,lw,lw2,icount,maxbl,maxseg,lbcprd,
     .                     nbcj0,nbck0,nbci0,nbcjdim,nbckdim,
     .                     nbcidim,jbcinfo,kbcinfo,ibcinfo,
     .                     igridg,jdimg,kdimg,idimg,isav_prd,
     .                     is_prd,ie_prd,nbcprd,nou,bou,nbuf,ibufdim,
     .                     bcvali,bcvalj,bcvalk,myid,nblg,maxgr,
     .                     ierrflg)
      use ginfo_x
!$acc routine seq
!$acc routine(lead) seq
c
c     $Id: pre_period.F,v 1.4 2003/05/15 20:25:13 rumsey Exp $
c
c***********************************************************************
c      Purpose: Set up data arrays for periodic bc message passing
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      character*120 bou(ibufdim,nbuf)
c
      dimension nou(nbuf)
      dimension lw(65,maxbl),lw2(43,maxbl),nblg(maxgr)
      dimension bcvali(maxbl,maxseg,12,2),bcvalj(maxbl,maxseg,12,2),
     .          bcvalk(maxbl,maxseg,12,2)
      dimension nbci0(maxbl),nbcidim(maxbl),nbcj0(maxbl),nbcjdim(maxbl),
     .          nbck0(maxbl),nbckdim(maxbl),ibcinfo(maxbl,maxseg,7,2),
     .          jbcinfo(maxbl,maxseg,7,2),kbcinfo(maxbl,maxseg,7,2)
      dimension igridg(maxbl),jdimg(maxbl),kdimg(maxbl),idimg(maxbl)
      dimension isav_prd(lbcprd,12),is_prd(5),ie_prd(5)
c
c      common /ginfo/ jdim,kdim,idim,jj2,kk2,ii2,nblc,js,ks,is,je,ke,ie,
c     .        lq,lqj0,lqk0,lqi0,lsj,lsk,lsi,lvol,ldtj,lx,ly,lz,lvis,
c     .        lsnk0,lsni0,lq1,lqr,lblk,lxib,lsig,lsqtq,lg,
c     .        ltj0,ltk0,lti0,lxkb,lnbl,lvj0,lvk0,lvi0,lbcj,lbck,lbci,
c     .        lqc0,ldqc0,lxtbi,lxtbj,lxtbk,latbi,latbj,latbk,
c     .        lbcdj,lbcdk,lbcdi,lxib2,lux,lcmuv,lvolj0,lvolk0,lvoli0,
c     .        lxmdj,lxmdk,lxmdi,lvelg,ldeltj,ldeltk,ldelti,
c     .        lxnm2,lynm2,lznm2,lxnm1,lynm1,lznm1,lqavg
c
      call lead(nbl,lw,lw2,maxbl)
c
c     check for 2005 type bcs
c
      do 802 nseg=1,nbci0(nbl)
      ista = 1
      iend = 1
      jsta = ibcinfo(nbl,nseg,2,1)
      jend = ibcinfo(nbl,nseg,3,1)
      ksta = ibcinfo(nbl,nseg,4,1)
      kend = ibcinfo(nbl,nseg,5,1)
      mdim = jend-jsta
      ndim = kend-ksta
      if (ibcinfo(nbl,nseg,1,1).eq.2005) then
         nblp = nblg(int(bcvali(nbl,nseg,1,1))) 
     .        + (nbl - nblg(igridg(nbl)))
         nface  = 1
         icount = icount + 1
         isav_prd(icount,1)  = nbl
         isav_prd(icount,2)  = nface
         isav_prd(icount,3)  = ista
         isav_prd(icount,4)  = iend
         isav_prd(icount,5)  = jsta 
         isav_prd(icount,6)  = jend 
         isav_prd(icount,7)  = ksta
         isav_prd(icount,8)  = kend
         isav_prd(icount,9)  = mdim
         isav_prd(icount,10) = ndim
         isav_prd(icount,11) = nseg
         isav_prd(icount,12) = nblp
      end if
  802 continue
c
      do 803 nseg=1,nbcidim(nbl)
      ista = idim
      iend = idim
      jsta = ibcinfo(nbl,nseg,2,2)
      jend = ibcinfo(nbl,nseg,3,2)
      ksta = ibcinfo(nbl,nseg,4,2)
      kend = ibcinfo(nbl,nseg,5,2)
      mdim = jend-jsta
      ndim = kend-ksta
      if (ibcinfo(nbl,nseg,1,2).eq.2005) then
         nblp = nblg(int(bcvali(nbl,nseg,1,2))) 
     .        + (nbl - nblg(igridg(nbl)))
         nface  = 2 
         icount = icount + 1
         isav_prd(icount,1)  = nbl
         isav_prd(icount,2)  = nface
         isav_prd(icount,3)  = ista
         isav_prd(icount,4)  = iend
         isav_prd(icount,5)  = jsta
         isav_prd(icount,6)  = jend
         isav_prd(icount,7)  = ksta
         isav_prd(icount,8)  = kend
         isav_prd(icount,9)  = mdim
         isav_prd(icount,10) = ndim
         isav_prd(icount,11) = nseg
         isav_prd(icount,12) = nblp
      end if
  803 continue
c
      do 804 nseg=1,nbcj0(nbl)
      ista = jbcinfo(nbl,nseg,2,1)
      iend = jbcinfo(nbl,nseg,3,1)
      jsta = 1
      jend = 1
      ksta = jbcinfo(nbl,nseg,4,1)
      kend = jbcinfo(nbl,nseg,5,1)
      mdim = kend-ksta
      ndim = iend-ista
      if (jbcinfo(nbl,nseg,1,1).eq.2005) then
         nblp = nblg(int(bcvalj(nbl,nseg,1,1))) 
     .        + (nbl - nblg(igridg(nbl)))
         nface  = 3
         icount = icount + 1
         isav_prd(icount,1)  = nbl
         isav_prd(icount,2)  = nface
         isav_prd(icount,3)  = ista
         isav_prd(icount,4)  = iend
         isav_prd(icount,5)  = jsta
         isav_prd(icount,6)  = jend
         isav_prd(icount,7)  = ksta
         isav_prd(icount,8)  = kend
         isav_prd(icount,9)  = mdim
         isav_prd(icount,10) = ndim
         isav_prd(icount,11) = nseg
         isav_prd(icount,12) = nblp
      end if
  804 continue
c
      do 805 nseg=1,nbcjdim(nbl)
      ista = jbcinfo(nbl,nseg,2,2)
      iend = jbcinfo(nbl,nseg,3,2)
      jsta = jdim
      jend = jdim
      ksta = jbcinfo(nbl,nseg,4,2)
      kend = jbcinfo(nbl,nseg,5,2)
      mdim = kend-ksta
      ndim = iend-ista
      if (jbcinfo(nbl,nseg,1,2).eq.2005) then
         nblp = nblg(int(bcvalj(nbl,nseg,1,2))) 
     .        + (nbl - nblg(igridg(nbl)))
         nface  = 4
         icount = icount + 1
         isav_prd(icount,1)  = nbl
         isav_prd(icount,2)  = nface
         isav_prd(icount,3)  = ista
         isav_prd(icount,4)  = iend
         isav_prd(icount,5)  = jsta
         isav_prd(icount,6)  = jend
         isav_prd(icount,7)  = ksta
         isav_prd(icount,8)  = kend
         isav_prd(icount,9)  = mdim
         isav_prd(icount,10) = ndim
         isav_prd(icount,11) = nseg
         isav_prd(icount,12) = nblp
      end if
  805 continue
c
      do 806 nseg=1,nbck0(nbl)
      ista = kbcinfo(nbl,nseg,2,1)
      iend = kbcinfo(nbl,nseg,3,1)
      jsta = kbcinfo(nbl,nseg,4,1)
      jend = kbcinfo(nbl,nseg,5,1)
      ksta = 1
      kend = 1
      mdim = jend-jsta
      ndim = iend-ista
      if (kbcinfo(nbl,nseg,1,1).eq.2005) then
         nblp = nblg(int(bcvalk(nbl,nseg,1,1))) 
     .        + (nbl - nblg(igridg(nbl)))
         nface  = 5
         icount = icount + 1
         isav_prd(icount,1)  = nbl
         isav_prd(icount,2)  = nface
         isav_prd(icount,3)  = ista
         isav_prd(icount,4)  = iend
         isav_prd(icount,5)  = jsta
         isav_prd(icount,6)  = jend
         isav_prd(icount,7)  = ksta
         isav_prd(icount,8)  = kend
         isav_prd(icount,9)  = mdim
         isav_prd(icount,10) = ndim
         isav_prd(icount,11) = nseg
         isav_prd(icount,12) = nblp
      end if
  806 continue
c
      do 807 nseg=1,nbckdim(nbl)
      ista = kbcinfo(nbl,nseg,2,2)
      iend = kbcinfo(nbl,nseg,3,2)
      jsta = kbcinfo(nbl,nseg,4,2)
      jend = kbcinfo(nbl,nseg,5,2)
      ksta = kdim
      kend = kdim
      mdim = jend-jsta
      ndim = iend-ista
      if (kbcinfo(nbl,nseg,1,2).eq.2005) then
         nblp = nblg(int(bcvalk(nbl,nseg,1,2))) 
     .        + (nbl - nblg(igridg(nbl)))
         nface  = 6
         icount = icount + 1
         isav_prd(icount,1)  = nbl
         isav_prd(icount,2)  = nface
         isav_prd(icount,3)  = ista
         isav_prd(icount,4)  = iend
         isav_prd(icount,5)  = jsta
         isav_prd(icount,6)  = jend
         isav_prd(icount,7)  = ksta
         isav_prd(icount,8)  = kend
         isav_prd(icount,9)  = mdim
         isav_prd(icount,10) = ndim
         isav_prd(icount,11) = nseg
         isav_prd(icount,12) = nblp
      end if
  807 continue
c
      nbcprd = icount
c
      if (nbcprd.gt.lbcprd) then
         nou(1) = min(nou(1)+1,ibufdim)
c         write(bou(nou(1),1),*)'  Stopping in pre_period:'
         nou(1) = min(nou(1)+1,ibufdim)
c         write(bou(nou(1),1),*)'  nbcprd too small'
c         call termn8(myid,ierrflg,ibufdim,nbuf,bou,nou)
      end if
c
      return
      end
