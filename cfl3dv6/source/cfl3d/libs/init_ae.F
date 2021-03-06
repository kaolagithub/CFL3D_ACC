      subroutine init_ae(nmds,maxaes,x0,xxn,temp,bmat,stm,stmi,gforcn,
     .                   gforcnm,freq,damp,gmass,aesrfdat,xs,gforcs)
      use elastic_x
      use info_x
c
c     $Id: init_ae.F,v 1.2 2001/05/25 20:00:06 biedron Exp $
c
c***********************************************************************
c     Purpose: initialize aeroelastic data, and calculate the stm, 
c              stmi, and bmat arrays used for the solution to the
c              modal equations, where stm is the state transition
c              matrix, stmi is the integral of the stm, and bmat
c              is the array containing the generalized masses. These
c              arrays depend only on the structural properties and time 
c              step, so need only to be calculated once, at the start
c              of a calculation. Note that ainf=uinf/xmach is used for
c              the non-dimensionalization of time in the structural
c              equations of motion.
c              
c        Reference: Cunningham, H.J., Batina, J.T., and Bennett, R.M,
c                  "Modern Wing Flutter Analysis by Computational Fluid
c                   Dynamics Methods," J. Aircraft, Vol. 25, No. 10,
c                   October 1988, pp. 962-968.
c
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      dimension aesrfdat(5,maxaes),temp(2*nmds,2*nmds),
     .           freq(nmds,maxaes),gmass(nmds,maxaes),damp(nmds,maxaes)
      dimension bmat(2*nmds,2*nmds,maxaes),gforcn(2*nmds,maxaes),
     .          gforcnm(2*nmds,maxaes),gforcs(2*nmds,maxaes),
     .          stm(2*nmds,2*nmds,maxaes),stmi(2*nmds,2*nmds,maxaes),
     .          xs(2*nmds,maxaes),xxn(2*nmds,maxaes),x0(2*nmds,maxaes)
c
c      common /elastic/ ndefrm,naesrf
c      common /info/ title(20),rkap(3),xmach,alpha,beta,dt,fmax,nit,ntt,
c     .        idiag(3),nitfo,iflagts,iflim(3),nres,levelb(5),mgflag,
c     .        iconsf,mseq,ncyc1(5),levelt(5),nitfo1(5),ngam,nsm(5),iipv
c
      do iaes=1,naesrf
c
         iskyhk = aesrfdat(1,iaes)
         grefl  = aesrfdat(2,iaes)
         uinf   = aesrfdat(3,iaes)
         qinf   = aesrfdat(4,iaes)
         nmodes = aesrfdat(5,iaes)
         ainf   = uinf/xmach
         rgrefl = 1./grefl
c
         do m=1,2*nmodes
            do n = 1,2*nmodes
               stm(n,m,iaes)   = 0.
               stmi(n,m,iaes)  = 0.
               bmat(n,m,iaes)  = 0.
               gforcn(m,iaes)  = 0.
               gforcnm(m,iaes) = 0.
               xxn(m,iaes)     = x0(m,iaes)
               xs(m,iaes)      = x0(m,iaes)
            end do
         end do
c
         do i=1,2*nmodes-1,2
c
            j = (i+1)/2
c
            aa =-freq(j,iaes)*damp(j,iaes)
            bb = freq(j,iaes)*sqrt(1.-damp(j,iaes)*damp(j,iaes))
            ec = exp(aa*dt*grefl/ainf)*cos(bb*dt*grefl/ainf)
            es = exp(aa*dt*grefl/ainf)*sin(bb*dt*grefl/ainf)
c
            stm( i , i ,iaes)  =   ec -aa*es/bb
            stm( i ,i+1,iaes)  =   es/bb
            stm(i+1, i ,iaes)  = -(aa*aa+bb*bb)*es/bb
            stm(i+1,i+1,iaes)  =   ec +aa*es/bb
c
            stmi( i , i ,iaes) = (2.0*aa*(ec-1.) 
     .                         + (bb - aa*aa/bb)*es)
     .                         / (aa*aa + bb*bb)
            stmi( i ,i+1,iaes) = (aa*es/bb - ec + 1.)
     .                         / (aa*aa + bb*bb)
            stmi(i+1, i ,iaes) = -aa*es/bb + ec - 1.
            stmi(i+1,i+1,iaes) = es/bb
c
            bmat(i+1,i+1,iaes) = 1./gmass(j,iaes)
c
         end do
c
c        overwrite stmi with matrix product stmi*bmat
c        (theta*B in the references's notation)
c
         do j=1,2*nmodes
            do i=1,2*nmodes
               temp(i,j) = 0.
               do k=1,2*nmodes
                  temp(i,j) = temp(i,j) 
     .                      + stmi(i,k,iaes)*bmat(k,j,iaes)
               end do
            end do
         end do
         do j=1,2*nmodes
            do i=1,2*nmodes
               stmi(i,j,iaes) = temp(i,j)
            end do
         end do
c
      end do
c
      return
      end
