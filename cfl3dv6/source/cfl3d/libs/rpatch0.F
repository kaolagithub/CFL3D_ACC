      subroutine rpatch0(intmx,msub1,iindex,ninter)
      use params_x
c
c     $Id: rpatch0.F,v 1.2 2001/05/25 20:00:08 biedron Exp $
c
c***********************************************************************
c     Purpose: Read in generalized-coordinate interpolation data
c     from a file; only the data needed to evaluate sizing 
c     requirements are stored at this time (this is a modified
c     version of subroutine rpatch)
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      real dum
c
c      common /params/ lmaxgr,lmaxbl,lmxseg,lmaxcs,lnplts,lmxbli,lmaxxe,
c     .                lnsub1,lintmx,lmxxe,liitot,isum,lncycm,
c     .                isum_n,lminnode,isumi,isumi_n,lmptch,
c     .                lmsub1,lintmax,libufdim,lnbuf,llbcprd,
c     .                llbcemb,llbcrad,lnmds,lmaxaes,lnslave,lmxsegdg,
c     .                lnmaster
c
      dimension iindex(intmx,2*msub1+9)
c
c     read patched-grid connectivity file
c
      read(22) ninter
      lintmax = ninter
      lnsub1 = 0
      do 1500 n=1,abs(ninter)
      read(22) iindex(n,1)
      nfb = iindex(n,1)
      lnsub1 = max(lnsub1,nfb)
      read(22) (iindex(n,1+ll),ll=1,nfb)
      read(22) iindex(n,nfb+2)
      idum1 = iindex(n,nfb+2)
      read(22) (iindex(n,nfb+2+ll),ll=1,nfb)
      read(22) iindex(n,2*nfb+3)
      read(22) iindex(n,2*nfb+4)
      idum2 = iindex(n,2*nfb+4)
      read(22) iindex(n,2*nfb+5)
      idum3 = iindex(n,2*nfb+5)
      read(22) iindex(n,2*nfb+6)
      read(22) iindex(n,2*nfb+7)
      read(22) iindex(n,2*nfb+8)
      read(22) iindex(n,2*nfb+9)
      nbl = idum1
      lst  =idum3
      len = lst + idum2 - 1
      read(22) (ndum,nnn=lst,len)
      read(22) ((dum,nnn=lst,len),ll=1,2)
 1500 continue
c
c     don't need to read angular displacements for
c     sizing purposes
c
      lmaxxe = len
c
c     set ninter = -ninter to allow full read of
c     the patch file in subroutine setup
c
      ninter = -ninter
c
      return
      end
