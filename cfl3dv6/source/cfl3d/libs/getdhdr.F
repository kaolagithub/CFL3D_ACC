      subroutine getdhdr(datahdr,ibctyp,ndata)
c
c     $Id: getdhdr.F,v 1.4 2003/05/09 19:48:01 rumsey Exp $
c
c***********************************************************************
c     Purpose:  To set character data for main output file headers 
c     when the 2000 series bc's are used 
c***********************************************************************
c
#   ifdef CMPLX
      implicit complex(a-h,o-z)
#   endif
c
      character*10 datahdr(10)
c
      do 1 m=1,10
    1 datahdr(m)  = '          '
c
      if (ibctyp.eq.2002) then
         datahdr(1)  = '    p/pinf'
      end if
c
      if (ibctyp.eq.2003) then
         datahdr(1)  = '      mach'
         datahdr(2)  = '   pt/pinf'
         datahdr(3)  = '   tt/tinf'
         datahdr(4)  = '     alpha'
         datahdr(5)  = '      beta'
         if (abs(ndata).gt.5) then
            datahdr(6)  = '     turb1'
         end if
         if (abs(ndata).gt.6) then
            datahdr(7)  = '     turb2'
         end if
      end if
c
      if (ibctyp.eq.2009) then
         datahdr(1)  = '   pt/pinf'
         datahdr(2)  = '   tt/tinf'
         datahdr(3)  = '     alpha'
         datahdr(4)  = '      beta'
         if (abs(ndata).gt.4) then
            datahdr(5)  = '     turb1'
         end if
         if (abs(ndata).gt.5) then
            datahdr(6)  = '     turb2'
         end if
      end if
c
      if (abs(ibctyp).eq.2004 .or. abs(ibctyp).eq.2014) then
         datahdr(1)  = '   tw/tinf'
         datahdr(2)  = '        cq'
      end if
c
      if (ibctyp.eq.2005) then
         datahdr(1)  = '      nblp'
         datahdr(2)  = '     dthtx'
         datahdr(3)  = '     dthty'
         datahdr(4)  = '     dthtz'
      end if
c
      if (ibctyp.eq.2006) then
         datahdr(1)  = '      nblc'
         datahdr(2)  = '    p/pinf'
         datahdr(3)  = ' integ dir'
         datahdr(4)  = ' axial dir'
      end if
c
      if (ibctyp.eq.2007) then
         datahdr(1)  = '       rho'
         datahdr(2)  = '         u'
         datahdr(3)  = '         v'
         datahdr(4)  = '         w'
         datahdr(5)  = '         p'
         if (abs(ndata).gt.5) then
            datahdr(6)  = '     turb1'
         end if
         if (abs(ndata).gt.6) then
            datahdr(7)  = '     turb2'
         end if
      end if
c
      if (ibctyp.eq.2102) then
         datahdr(1) = '    p/pinf'
         datahdr(2) = '   dp/pinf'
         datahdr(3) = '    rfreqp'
         datahdr(4) = '      lref'
      end if
c
      if (ibctyp.eq.2008) then
         datahdr(1)  = '       rho'
         datahdr(2)  = '         u'
         datahdr(3)  = '         v'
         datahdr(4)  = '         w'
         if (abs(ndata).gt.4) then
            datahdr(5)  = '     turb1'
         end if
         if (abs(ndata).gt.5) then
            datahdr(6)  = '     turb2'
         end if
      end if
c
      if (ibctyp.eq.2018) then
         datahdr(1)  = '         T'
         datahdr(2)  = '      rhou'
         datahdr(3)  = '      rhov'
         datahdr(4)  = '      rhow'
         if (abs(ndata).gt.4) then
            datahdr(5)  = '     turb1'
         end if
         if (abs(ndata).gt.5) then
            datahdr(6)  = '     turb2'
         end if
      end if
c
      if (ibctyp.eq.2028) then
         datahdr(1)  = '      freq'
         datahdr(2)  = '   rhoumax'
         datahdr(3)  = '   rhovmax'
         datahdr(4)  = '   rhowmax'
         if (abs(ndata).gt.4) then
            datahdr(5)  = '     turb1'
         end if
         if (abs(ndata).gt.5) then
            datahdr(6)  = '     turb2'
         end if
      end if
c
      return
      end
