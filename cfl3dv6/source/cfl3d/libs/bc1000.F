      subroutine bc1000(jdim,kdim,idim,q,qj0,qk0,qi0,sj,sk,si,bcj,bck,
     .                  bci,xtbj,xtbk,xtbi,atbj,atbk,atbi,ista,iend,
     .                  jsta,jend,ksta,kend,nface,tursav,tj0,tk0,
     .                  ti0,vist3d,vj0,vk0,vi0,iuns,nou,bou,nbuf,
     .                  ibufdim)
      use ivals_x
      use mgrd_x
      use reyue_x
      use sklton_x
c
c     $Id: bc1000.F,v 1.3 2003/05/09 19:47:52 rumsey Exp $
c
c***********************************************************************
c     Purpose:  Set freestream boundary conditions 
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      character*120 bou(ibufdim,nbuf)
c
      dimension nou(nbuf)
      dimension q(jdim,kdim,idim,5), qi0(jdim,kdim,5,4),
     .          qj0(kdim,idim-1,5,4),qk0(jdim,idim-1,5,4)
      dimension sk(jdim,kdim,idim-1,5),si(jdim,kdim,idim,5),
     .          sj(jdim,kdim,idim-1,5)
      dimension bcj(kdim,idim-1,2),bck(jdim,idim-1,2),bci(jdim,kdim,2)
      dimension xtbj(kdim,idim-1,3,2),xtbk(jdim,idim-1,3,2),
     .          xtbi(jdim,kdim,3,2),atbj(kdim,idim-1,3,2),
     .          atbk(jdim,idim-1,3,2),atbi(jdim,kdim,3,2)
      dimension tursav(jdim,kdim,idim,2),tj0(kdim,idim-1,2,4),
     .          tk0(jdim,idim-1,2,4),ti0(jdim,kdim,2,4),
     .          vj0(kdim,idim-1,1,4),vk0(jdim,idim-1,1,4),
     .          vi0(jdim,kdim,1,4),vist3d(jdim,kdim,idim)
c
c      common /ivals/ p0,rho0,c0,u0,v0,w0,et0,h0,pt0,rhot0,qiv(5),
c     .        tur10,tur20
c      common /mgrd/ levt,kode,mode,ncyc,mtt,icyc,level,lglobal
c      common /reyue/ reue,tinf,ivisc(3)
c      common /sklton/ isklton
c
      jdim1 = jdim-1
      kdim1 = kdim-1
      idim1 = idim-1
c
      jend1 = jend-1
      kend1 = kend-1
      iend1 = iend-1
c
c            * * * * * * * * * * * * * * * * * * * * * *
c            * standard boundary condition bctype=1000 *
c            * * * * * * * * * * * * * * * * * * * * * *
c
c******************************************************************************
c      j=1 boundary            freestream                           bctype 1000
c******************************************************************************
c
      if (nface.eq.3) then
      do 100 l=1,5
      do 100 i=ista,iend1
      do 100 k=ksta,kend1
      qj0(k,i,l,1) = qiv(l)
      qj0(k,i,l,2) = qj0(k,i,l,1)
      bcj(k,i,1)   = 0.0
  100 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 191 i=ista,iend1
        do 191 k=ksta,kend1
          vj0(k,i,1,1) = vist3d(1,k,i)
          vj0(k,i,1,2) = 0.
  191   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 101 i=ista,iend1
        do 101 k=ksta,kend1
          tj0(k,i,1,1) = tur10
          tj0(k,i,2,1) = tur20
          tj0(k,i,1,2) = tur10
          tj0(k,i,2,2) = tur20
  101   continue
      end if
      end if
      end if
c
c******************************************************************************
c      j=jdim boundary             freestream                       bctype 1000
c******************************************************************************
c
      if (nface.eq.4) then
      do 200 l=1,5
      do 200 i=ista,iend1
      do 200 k=ksta,kend1
      qj0(k,i,l,3) = qiv(l)
      qj0(k,i,l,4) = qj0(k,i,l,3)
      bcj(k,i,2)   = 0.0
  200 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 291 i=ista,iend1
        do 291 k=ksta,kend1
          vj0(k,i,1,3) = vist3d(jdim-1,k,i)
          vj0(k,i,1,4) = 0.0
  291   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 201 i=ista,iend1
        do 201 k=ksta,kend1
          tj0(k,i,1,3) = tur10
          tj0(k,i,2,3) = tur20
          tj0(k,i,1,4) = tur10
          tj0(k,i,2,4) = tur20
  201   continue
      end if
      end if
      end if
c
c******************************************************************************
c      k=1 boundary            freestream                           bctype 1000
c******************************************************************************
c
      if (nface.eq.5) then
      do 300 l=1,5
      do 300 i=ista,iend1
      do 300 j=jsta,jend1
      qk0(j,i,l,1) = qiv(l)
      qk0(j,i,l,2) = qk0(j,i,l,1)
      bck(j,i,1)   = 0.0
  300 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 391 i=ista,iend1
        do 391 j=jsta,jend1
          vk0(j,i,1,1) = vist3d(j,1,i)
          vk0(j,i,1,2) = 0.0
  391   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 301 i=ista,iend1
        do 301 j=jsta,jend1
          tk0(j,i,1,1) = tur10
          tk0(j,i,2,1) = tur20
          tk0(j,i,1,2) = tur10
          tk0(j,i,2,2) = tur20
  301   continue
      end if
      end if
      end if
c
c******************************************************************************
c      k=kdim boundary             freestream                       bctype 1000
c******************************************************************************
c
      if (nface.eq.6) then
      do 400 l=1,5
      do 400 i=ista,iend1
      do 400 j=jsta,jend1
      qk0(j,i,l,3) = qiv(l)
      qk0(j,i,l,4) = qk0(j,i,l,3)
      bck(j,i,2)   = 0.0
  400 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 491 i=ista,iend1
        do 491 j=jsta,jend1
          vk0(j,i,1,3) = vist3d(j,kdim-1,i)
          vk0(j,i,1,4) = 0.0
  491   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 401 i=ista,iend1
        do 401 j=jsta,jend1
          tk0(j,i,1,3) = tur10
          tk0(j,i,2,3) = tur20
          tk0(j,i,1,4) = tur10
          tk0(j,i,2,4) = tur20
  401   continue
      end if
      end if
      end if
c
c******************************************************************************
c      i=1 boundary            freestream                           bctype 1000
c******************************************************************************
c
      if (nface.eq.1) then
      do 500 l=1,5
      do 500 k=ksta,kend1
      do 500 j=jsta,jend1
      qi0(j,k,l,1) = qiv(l)
      qi0(j,k,l,2) = qi0(j,k,l,1)
      bci(j,k,1)   = 0.0
  500 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 591 k=ksta,kend1
        do 591 j=jsta,jend1
          vi0(j,k,1,1) = vist3d(j,k,1)
          vi0(j,k,1,2) = 0.0
  591   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 501 k=ksta,kend1
        do 501 j=jsta,jend1
          ti0(j,k,1,1) = tur10
          ti0(j,k,2,1) = tur20
          ti0(j,k,1,2) = tur10
          ti0(j,k,2,2) = tur20
  501   continue
      end if
      end if
      end if
c
c******************************************************************************
c      i=idim boundary             freestream                       bctype 1000
c******************************************************************************
c
      if (nface.eq.2) then
      do 600 l=1,5
      do 600 k=ksta,kend1
      do 600 j=jsta,jend1
      qi0(j,k,l,3) = qiv(l)
      qi0(j,k,l,4) = qi0(j,k,l,3)
      bci(j,k,2)   = 0.0
  600 continue
      if (ivisc(3).ge.2 .or. ivisc(2).ge.2 .or. ivisc(1).ge.2) then
        do 691 k=ksta,kend1
        do 691 j=jsta,jend1
          vi0(j,k,1,3) = vist3d(j,k,idim-1)
          vi0(j,k,1,4) = 0.0
  691   continue
      end if
c   only need to do advanced model turbulence B.C.s on finest grid
      if (level .ge. lglobal) then
      if (ivisc(3).ge.4 .or. ivisc(2).ge.4 .or. ivisc(1).ge.4) then
        do 601 k=ksta,kend1
        do 601 j=jsta,jend1
          ti0(j,k,1,3) = tur10
          ti0(j,k,2,3) = tur20
          ti0(j,k,1,4) = tur10
          ti0(j,k,2,4) = tur20
  601   continue
      end if
      end if
      end if
c
      return
      end
