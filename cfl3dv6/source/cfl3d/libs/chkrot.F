      subroutine chkrot(nbl,jdim,kdim,idim,x,y,z,nblp,jdimp,kdimp,
     .                  idimp,xp,yp,zp,nface,bcdata,xyzjp,xyzkp,xyzip,
     .                  ista,iend,jsta,jend,ksta,kend,mdim,ndim,lcnt,
     .                  xorig,yorig,zorig,maxbl,period_miss,lbcprd,
     .                  nou,bou,nbuf,ibufdim,myid)
      use conversion_x
c
c     $Id: chkrot.F,v 1.3 2003/05/15 20:25:10 rumsey Exp $
c
c***********************************************************************
c     Purpose:  Check to make sure that the proper rotation angle for
c     periodic boundary conditions has been set. The check is done by
c     rotating the periodic block face through the specified angle, then
c     checking for point-to-point match with the current block face.
c
c     if i=1 is the periodic face in block nbl, it is assumed periodic 
c     with i=idim in block nblp. if i=idim is the periodic face in block
c     nbl, it is assumed periodic with i=1  in block nblp. furthermore,
c     it is assumed that j and k run in the same direction in blocks
c     nbl and nblp. similar assumptions hold when j or k faces are 
c     periodic. nbl and nblp may be identical, but they need not be.
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      character*120 bou(ibufdim,nbuf)
c
      dimension nou(nbuf)
      dimension x(jdim,kdim,idim),y(jdim,kdim,idim),z(jdim,kdim,idim),
     .          xp(jdim,kdim,idim),yp(jdim,kdim,idim),
     .          zp(jdim,kdim,idim) 
      dimension xyzjp(kdim,idim,3),xyzkp(jdim,idim,3),xyzip(jdim,kdim,3) 
      dimension bcdata(mdim,ndim,2,12),period_miss(lbcprd)
      dimension xorig(maxbl),yorig(maxbl),zorig(maxbl)
c
c      common /conversion/ radtodeg
c
      ip = 1
c
      dthtx = bcdata(1,1,ip,2)/radtodeg
      dthty = bcdata(1,1,ip,3)/radtodeg
      dthtz = bcdata(1,1,ip,4)/radtodeg
c
c     check that only one of dthtx,dthty,dthtz is non-zero
c
      if (dthtx.ne.0) then
	 if (dthty.ne.0. .or. dthtz.ne.0.) then 
            nou(1) = min(nou(1)+1,ibufdim)
	    write(bou(nou(1),1),101)
	    call termn8(myid,-1,ibufdim,nbuf,bou,nou)
	 end if
      end if
      if (dthty.ne.0) then
	 if (dthtx.ne.0. .or. dthtz.ne.0.) then
            nou(1) = min(nou(1)+1,ibufdim)
	    write(bou(nou(1),1),101)
	    call termn8(myid,-1,ibufdim,nbuf,bou,nou)
	 end if
      end if
      if (dthtz.ne.0) then
	 if (dthtx.ne.0. .or. dthty.ne.0.) then
            nou(1) = min(nou(1)+1,ibufdim)
	    write(bou(nou(1),1),101)
	    call termn8(myid,-1,ibufdim,nbuf,bou,nou)
	 end if
      end if
c
      eps = 0
c
c     i=1 boundary
c
      if (nface.eq.1) then
c
         i  = 1
         ip = idimp
c
c        check that jdim = jdimp and kdim = kdimp
c
	 if (jdim.ne.jdimp .or. kdim.ne.kdimp) then
            nou(1) = min(nou(1)+1,ibufdim)
	    write(bou(nou(1),1),102)
            nou(1) = min(nou(1)+1,ibufdim)
	    write(bou(nou(1),1),103) jdim,kdim,jdimp,kdimp
	    call termn8(myid,-1,ibufdim,nbuf,bou,nou)
	 end if
c
c        load x,y,z values on periodic face into work array
c
	 do 1000 j=1,jdimp
	 do 1000 k=1,kdimp
	 xyzip(j,k,1) = xp(j,k,ip)
	 xyzip(j,k,2) = yp(j,k,ip)
	 xyzip(j,k,3) = zp(j,k,ip)
 1000    continue
c
c        rotate periodic block face (entire face)
c
         jdum = jdimp
         kdum = kdimp
         idum = 1
         call grdmove(nblp,jdum,kdum,idum,xyzip(1,1,1),xyzip(1,1,2),
     .                xyzip(1,1,3),xorig(nblp),yorig(nblp),zorig(nblp),
     .                xorig(nblp),yorig(nblp),zorig(nblp),dthtx,dthty,
     .                dthtz)
c
c        check for point match
c
         do 1010 j=jsta,jend
         do 1010 k=ksta,kend
         xt1 = x(j,k,i)
         yt1 = y(j,k,i)
         zt1 = z(j,k,i)
         xr1 = xyzip(j,k,1)
         yr1 = xyzip(j,k,2)
         zr1 = xyzip(j,k,3)
         eps = ccmax(eps,sqrt((xr1-xt1)**2+(yr1-yt1)**2+(zr1-zt1)**2))
 1010    continue
c
         period_miss(lcnt) = eps
c
      end if
c
c     i=idim boundary
c
      if (nface.eq.2) then
c
         i  = idim
         ip = 1
c
c        check that jdim = jdimp and kdim = kdimp
c
         if (jdim.ne.jdimp .or. kdim.ne.kdimp) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),102)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),103) jdim,kdim,jdimp,kdimp
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
c
c        load x,y,z values on periodic face into work array
c
         do 2000 j=1,jdimp
         do 2000 k=1,kdimp
         xyzip(j,k,1) = xp(j,k,ip)
         xyzip(j,k,2) = yp(j,k,ip)
         xyzip(j,k,3) = zp(j,k,ip)
 2000    continue
c
c        rotate periodic block face (entire face)
c
         jdum = jdimp
         kdum = kdimp
         idum = 1
         call grdmove(nblp,jdum,kdum,idum,xyzip(1,1,1),xyzip(1,1,2),
     .                xyzip(1,1,3),xorig(nblp),yorig(nblp),zorig(nblp),
     .                xorig(nblp),yorig(nblp),zorig(nblp),dthtx,dthty,
     .                dthtz)
c
c        check for point match
c
         do 2010 j=jsta,jend
         do 2010 k=ksta,kend
         xt1 = x(j,k,i)
         yt1 = y(j,k,i)
         zt1 = z(j,k,i)
         xr1 = xyzip(j,k,1)
         yr1 = xyzip(j,k,2)
         zr1 = xyzip(j,k,3)
         eps = ccmax(eps,sqrt((xr1-xt1)**2+(yr1-yt1)**2+(zr1-zt1)**2))
 2010    continue
c
         period_miss(lcnt) = eps
c
      end if
c
c     j=1 boundary
c
      if (nface.eq.3) then
c
         j  = 1
         jp = jdimp
c
c        check that idim = idimp and kdim = kdimp
c
         if (idim.ne.idimp .or. kdim.ne.kdimp) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),102)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),104) idim,kdim,idimp,kdimp
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
c
c        load x,y,z values on periodic face into work array
c
         do 3000 i=1,idimp
         do 3000 k=1,kdimp
         xyzjp(k,i,1) = xp(jp,k,i)
         xyzjp(k,i,2) = yp(jp,k,i)
         xyzjp(k,i,3) = zp(jp,k,i)
 3000    continue
c
c        rotate periodic block face (entire face)
c
         jdum = 1
         kdum = kdimp
         idum = idimp
         call grdmove(nblp,jdum,kdum,idum,xyzjp(1,1,1),xyzjp(1,1,2),
     .                xyzjp(1,1,3),xorig(nblp),yorig(nblp),zorig(nblp),
     .                xorig(nblp),yorig(nblp),zorig(nblp),dthtx,dthty,
     .                dthtz)
c
c        check for point match
c
         do 3010 i=ista,iend
         do 3010 k=ksta,kend
         xt1 = x(j,k,i)
         yt1 = y(j,k,i)
         zt1 = z(j,k,i)
         xr1 = xyzjp(k,i,1)
         yr1 = xyzjp(k,i,2)
         zr1 = xyzjp(k,i,3)
         eps = ccmax(eps,sqrt((xr1-xt1)**2+(yr1-yt1)**2+(zr1-zt1)**2))
 3010    continue
c
         period_miss(lcnt) = eps
c
      end if
c
c     j=jdim boundary
c
      if (nface.eq.4) then
c
         j  = jdim
         jp = 1
c
c        check that idim = idimp and kdim = kdimp
c
         if (idim.ne.idimp .or. kdim.ne.kdimp) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),102)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),104) idim,kdim,idimp,kdimp
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
c
c        load x,y,z values on periodic face into work array
c
         do 4000 i=1,idimp
         do 4000 k=1,kdimp
         xyzjp(k,i,1) = xp(jp,k,i)
         xyzjp(k,i,2) = yp(jp,k,i)
         xyzjp(k,i,3) = zp(jp,k,i)
 4000    continue
c
c        rotate periodic block face (entire face)
c
         jdum = 1
         kdum = kdimp
         idum = idimp
         call grdmove(nblp,jdum,kdum,idum,xyzjp(1,1,1),xyzjp(1,1,2),
     .                xyzjp(1,1,3),xorig(nblp),yorig(nblp),zorig(nblp),
     .                xorig(nblp),yorig(nblp),zorig(nblp),dthtx,dthty,
     .                dthtz)
c
c        check for point match
c
         do 4010 i=ista,iend
         do 4010 k=ksta,kend
         xt1 = x(j,k,i)
         yt1 = y(j,k,i)
         zt1 = z(j,k,i)
         xr1 = xyzjp(k,i,1)
         yr1 = xyzjp(k,i,2)
         zr1 = xyzjp(k,i,3)
         eps = ccmax(eps,sqrt((xr1-xt1)**2+(yr1-yt1)**2+(zr1-zt1)**2))
 4010    continue
c
         period_miss(lcnt) = eps
c
      end if
c
c     k=1 boundary
c
      if (nface.eq.5) then
c
         k  = 1
         kp = kdimp
c
c        check that idim = idimp and jdim = jdimp
c
         if (idim.ne.idimp .or. jdim.ne.jdimp) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),102)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),105) idim,jdim,idimp,jdimp
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
c
c        load x,y,z values on periodic face into work array
c
         do 5000 i=1,idimp
         do 5000 j=1,jdimp
         xyzkp(j,i,1) = xp(j,kp,i)
         xyzkp(j,i,2) = yp(j,kp,i)
         xyzkp(j,i,3) = zp(j,kp,i)
 5000    continue
c
c        rotate periodic block face (entire face)
c
         jdum = jdimp
         kdum = 1
         idum = idimp
         call grdmove(nblp,jdum,kdum,idum,xyzkp(1,1,1),xyzkp(1,1,2),
     .                xyzkp(1,1,3),xorig(nblp),yorig(nblp),zorig(nblp),
     .                xorig(nblp),yorig(nblp),zorig(nblp),dthtx,dthty,
     .                dthtz)
c
c        check for point match
c
         do 5010 i=ista,iend
         do 5010 j=jsta,jend
         xt1 = x(j,k,i)
         yt1 = y(j,k,i)
         zt1 = z(j,k,i)
         xr1 = xyzkp(j,i,1)
         yr1 = xyzkp(j,i,2)
         zr1 = xyzkp(j,i,3)
         eps = ccmax(eps,sqrt((xr1-xt1)**2+(yr1-yt1)**2+(zr1-zt1)**2))
 5010    continue
c
         period_miss(lcnt) = eps
c
      end if
c
c     k=kdim boundary
c
      if (nface.eq.6) then
c
         k  = kdim
         kp = 1
c
c        check that idim = idimp and jdim = jdimp
c
         if (idim.ne.idimp .or. jdim.ne.jdimp) then
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),102)
            nou(1) = min(nou(1)+1,ibufdim)
            write(bou(nou(1),1),105) idim,jdim,idimp,jdimp
            call termn8(myid,-1,ibufdim,nbuf,bou,nou)
         end if
c
c        load x,y,z values on periodic face into work array
c
         do 6000 i=1,idimp
         do 6000 j=1,jdimp
         xyzkp(j,i,1) = xp(j,kp,i)
         xyzkp(j,i,2) = yp(j,kp,i)
         xyzkp(j,i,3) = zp(j,kp,i)
 6000    continue
c
c        rotate periodic block face (entire face)
c
         jdum = jdimp
         kdum = 1
         idum = idimp
         call grdmove(nblp,jdum,kdum,idum,xyzkp(1,1,1),xyzkp(1,1,2),
     .                xyzkp(1,1,3),xorig(nblp),yorig(nblp),zorig(nblp),
     .                xorig(nblp),yorig(nblp),zorig(nblp),dthtx,dthty,
     .                dthtz)
c
c        check for point match
c
         do 6010 i=ista,iend
         do 6010 j=jsta,jend
         xt1 = x(j,k,i)
         yt1 = y(j,k,i)
         zt1 = z(j,k,i)
         xr1 = xyzkp(j,i,1)
         yr1 = xyzkp(j,i,2)
         zr1 = xyzkp(j,i,3)
         eps = ccmax(eps,sqrt((xr1-xt1)**2+(yr1-yt1)**2+(zr1-zt1)**2))
 6010    continue
c
         period_miss(lcnt) = eps
c
      end if
c
 101  format(1x,41h2 of the 3 dtht values currently must = 0)
 102  format(1x,'periodic block face must be of the same 2 ',
     .          'dimensions (and orientation) as the current ',
     .          'block face')
 103  format(1x,24hjdim,kdim,jdimp,kdimp = ,4i5)
 104  format(1x,24hidim,kdim,idimp,kdimp = ,4i5)
 105  format(1x,24hidim,jdim,idimp,jdimp = ,4i5)
      return
      end
