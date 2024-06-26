      module mo_indprd
      use shr_kind_mod, only : r8 => shr_kind_r8
      private
      public :: indprd
      contains
      subroutine indprd( class, prod, nprod, y, extfrc, rxt, chnkpnts )
      use chem_mods, only : gas_pcnst, extcnt, rxntot
      implicit none
!--------------------------------------------------------------------
! ... dummy arguments
!--------------------------------------------------------------------
      integer, intent(in) :: class
      integer, intent(in) :: chnkpnts
      integer, intent(in) :: nprod
      real(r8), intent(in) :: y(chnkpnts,gas_pcnst)
      real(r8), intent(in) :: rxt(chnkpnts,rxntot)
      real(r8), intent(in) :: extfrc(chnkpnts,extcnt)
      real(r8), intent(inout) :: prod(chnkpnts,nprod)
!--------------------------------------------------------------------
! ... "independent" production for Explicit species
!--------------------------------------------------------------------
      if( class == 1 ) then
         prod(:,1) = + extfrc(:,17)
         prod(:,2) = 0._r8
         prod(:,3) = 0._r8
         prod(:,4) = 0._r8
         prod(:,5) = 0._r8
         prod(:,6) = 0._r8
         prod(:,7) = 0._r8
         prod(:,8) = 0._r8
         prod(:,9) = 0._r8
         prod(:,10) = 0._r8
         prod(:,11) = 0._r8
         prod(:,12) = 0._r8
         prod(:,13) = 0._r8
         prod(:,14) = 0._r8
         prod(:,15) =.100_r8*rxt(:,355)*y(:,157)*y(:,30)
         prod(:,16) = 0._r8
         prod(:,17) = 0._r8
         prod(:,18) = (2.000_r8*rxt(:,336)*y(:,250) +.900_r8*rxt(:,337)*y(:,251) + &
                 .490_r8*rxt(:,338)*y(:,256) +rxt(:,339)*y(:,147) + &
                 rxt(:,382)*y(:,282) +2.000_r8*rxt(:,389)*y(:,284) + &
                 rxt(:,401)*y(:,287) +rxt(:,425)*y(:,259) +rxt(:,431)*y(:,260) + &
                 rxt(:,445)*y(:,265) +rxt(:,449)*y(:,266) +rxt(:,475)*y(:,272) + &
                 rxt(:,492)*y(:,276) +rxt(:,496)*y(:,277) +rxt(:,587)*y(:,235) + &
                 rxt(:,595)*y(:,236) +rxt(:,607)*y(:,238) +rxt(:,615)*y(:,239) + &
                 rxt(:,627)*y(:,243) +rxt(:,635)*y(:,244) +rxt(:,646)*y(:,279) + &
                 rxt(:,655)*y(:,280) +rxt(:,666)*y(:,288) +rxt(:,675)*y(:,289) + &
                 rxt(:,694)*y(:,299) +2.000_r8*rxt(:,702)*y(:,300) + &
                 rxt(:,710)*y(:,301) +2.000_r8*rxt(:,720)*y(:,302) + &
                 rxt(:,729)*y(:,303) +rxt(:,739)*y(:,304) + &
                 2.000_r8*rxt(:,750)*y(:,305))*y(:,250) + (rxt(:,592)*y(:,235) + &
                 rxt(:,600)*y(:,236) +rxt(:,612)*y(:,238) +rxt(:,620)*y(:,239) + &
                 rxt(:,632)*y(:,243) +rxt(:,640)*y(:,244) +rxt(:,652)*y(:,279) + &
                 rxt(:,660)*y(:,280) +rxt(:,672)*y(:,288) +rxt(:,680)*y(:,289) + &
                 rxt(:,699)*y(:,299) +rxt(:,703)*y(:,251) + &
                 .490_r8*rxt(:,704)*y(:,256) +rxt(:,705)*y(:,147) + &
                 rxt(:,706)*y(:,149) +2.000_r8*rxt(:,707)*y(:,300) + &
                 2.000_r8*rxt(:,708)*y(:,305) +rxt(:,715)*y(:,301) + &
                 2.000_r8*rxt(:,725)*y(:,302) +rxt(:,734)*y(:,303) + &
                 rxt(:,744)*y(:,304))*y(:,300) + (rxt(:,593)*y(:,235) + &
                 rxt(:,601)*y(:,236) +rxt(:,613)*y(:,238) +rxt(:,621)*y(:,239) + &
                 rxt(:,633)*y(:,243) +rxt(:,641)*y(:,244) +rxt(:,653)*y(:,279) + &
                 rxt(:,661)*y(:,280) +rxt(:,673)*y(:,288) +rxt(:,681)*y(:,289) + &
                 rxt(:,700)*y(:,299) +rxt(:,716)*y(:,301) +rxt(:,721)*y(:,251) + &
                 .490_r8*rxt(:,722)*y(:,256) +rxt(:,723)*y(:,147) + &
                 rxt(:,724)*y(:,149) +2.000_r8*rxt(:,726)*y(:,302) + &
                 2.000_r8*rxt(:,727)*y(:,305) +rxt(:,735)*y(:,303) + &
                 rxt(:,745)*y(:,304))*y(:,302) + (rxt(:,594)*y(:,235) + &
                 rxt(:,602)*y(:,236) +rxt(:,614)*y(:,238) +rxt(:,622)*y(:,239) + &
                 rxt(:,634)*y(:,243) +rxt(:,642)*y(:,244) +rxt(:,654)*y(:,279) + &
                 rxt(:,662)*y(:,280) +rxt(:,674)*y(:,288) +rxt(:,682)*y(:,289) + &
                 rxt(:,701)*y(:,299) +rxt(:,717)*y(:,301) +rxt(:,736)*y(:,303) + &
                 rxt(:,746)*y(:,304) +rxt(:,751)*y(:,251) + &
                 .490_r8*rxt(:,752)*y(:,256) +rxt(:,753)*y(:,147) + &
                 rxt(:,754)*y(:,149) +2.000_r8*rxt(:,755)*y(:,305))*y(:,305) &
                  + (rxt(:,309)*y(:,63) +rxt(:,311)*y(:,90) +rxt(:,320)*y(:,63) + &
                 rxt(:,340)*y(:,51) +.500_r8*rxt(:,341)*y(:,52) + &
                 .800_r8*rxt(:,346)*y(:,76) +rxt(:,347)*y(:,77) +rxt(:,349)*y(:,150) + &
                 .540_r8*rxt(:,415)*y(:,98) +.540_r8*rxt(:,416)*y(:,99) + &
                 .360_r8*rxt(:,419)*y(:,103) +.190_r8*rxt(:,424)*y(:,108) + &
                 .450_r8*rxt(:,503)*y(:,139) +2.000_r8*rxt(:,719)*y(:,202) + &
                 3.000_r8*rxt(:,738)*y(:,204) +.290_r8*rxt(:,747)*y(:,206) + &
                 .290_r8*rxt(:,748)*y(:,207) +.290_r8*rxt(:,749)*y(:,205))*y(:,293) &
                  + (rxt(:,390)*y(:,251) +.490_r8*rxt(:,391)*y(:,256) + &
                 2.000_r8*rxt(:,392)*y(:,284) +rxt(:,393)*y(:,147) + &
                 rxt(:,394)*y(:,149))*y(:,284) + (.200_r8*rxt(:,355)*y(:,30) + &
                 .100_r8*rxt(:,404)*y(:,132) +.420_r8*rxt(:,487)*y(:,109) + &
                 .190_r8*rxt(:,643)*y(:,17))*y(:,157) +rxt(:,36)*y(:,52) &
                  +.170_r8*rxt(:,48)*y(:,98) +.280_r8*rxt(:,49)*y(:,99) +rxt(:,54) &
                 *y(:,103) +.400_r8*rxt(:,86)*y(:,162) +rxt(:,98)*y(:,205) +rxt(:,99) &
                 *y(:,206) +rxt(:,100)*y(:,207)
         prod(:,19) = 0._r8
         prod(:,20) = 0._r8
         prod(:,21) = 0._r8
         prod(:,22) = 0._r8
         prod(:,23) = 0._r8
         prod(:,24) =rxt(:,195)*y(:,148)*y(:,136)
         prod(:,25) = 0._r8
         prod(:,26) = 0._r8
         prod(:,27) = 0._r8
         prod(:,28) = 0._r8
         prod(:,29) = 0._r8
         prod(:,30) =rxt(:,811)*y(:,293)*y(:,143) +rxt(:,830)*y(:,144)
         prod(:,31) = (rxt(:,558)*y(:,252) +rxt(:,561)*y(:,283) +rxt(:,564)*y(:,285) + &
                 rxt(:,568)*y(:,164))*y(:,148)
!--------------------------------------------------------------------
! ... "independent" production for Implicit species
!--------------------------------------------------------------------
      else if( class == 4 ) then
         prod(:,140) = 0._r8
         prod(:,141) = 0._r8
         prod(:,185) = 0._r8
         prod(:,1) = + extfrc(:,10)
         prod(:,2) = + extfrc(:,11)
         prod(:,163) = 0._r8
         prod(:,56) = 0._r8
         prod(:,96) = 0._r8
         prod(:,57) = 0._r8
         prod(:,106) = 0._r8
         prod(:,83) = 0._r8
         prod(:,97) = 0._r8
         prod(:,87) = 0._r8
         prod(:,61) = 0._r8
         prod(:,94) = 0._r8
         prod(:,171) = 0._r8
         prod(:,233) =rxt(:,123)*y(:,35) +rxt(:,124)*y(:,36) +2.000_r8*rxt(:,130) &
                 *y(:,42) +rxt(:,131)*y(:,44) +3.000_r8*rxt(:,134)*y(:,56) &
                  +2.000_r8*rxt(:,142)*y(:,80)
         prod(:,69) = 0._r8
         prod(:,284) = 0._r8
         prod(:,122) = 0._r8
         prod(:,70) = 0._r8
         prod(:,90) = 0._r8
         prod(:,84) = 0._r8
         prod(:,123) = 0._r8
         prod(:,76) = 0._r8
         prod(:,91) = 0._r8
         prod(:,85) = 0._r8
         prod(:,195) = 0._r8
         prod(:,99) = 0._r8
         prod(:,50) = 0._r8
         prod(:,77) = 0._r8
         prod(:,278) =.180_r8*rxt(:,39)*y(:,55)
         prod(:,203) = 0._r8
         prod(:,48) = 0._r8
         prod(:,251) = 0._r8
         prod(:,240) = 0._r8
         prod(:,128) = 0._r8
         prod(:,119) = 0._r8
         prod(:,209) = 0._r8
         prod(:,104) = 0._r8
         prod(:,285) =4.000_r8*rxt(:,122)*y(:,34) +rxt(:,123)*y(:,35) &
                  +2.000_r8*rxt(:,125)*y(:,37) +2.000_r8*rxt(:,126)*y(:,38) &
                  +2.000_r8*rxt(:,127)*y(:,39) +rxt(:,128)*y(:,40) &
                  +2.000_r8*rxt(:,129)*y(:,41) +3.000_r8*rxt(:,132)*y(:,45) &
                  +rxt(:,133)*y(:,47) +rxt(:,144)*y(:,84) +rxt(:,145)*y(:,85) &
                  +rxt(:,146)*y(:,86)
         prod(:,55) = 0._r8
         prod(:,49) = 0._r8
         prod(:,277) = 0._r8
         prod(:,196) = 0._r8
         prod(:,223) =.380_r8*rxt(:,39)*y(:,55) +rxt(:,40)*y(:,64) + extfrc(:,9)
         prod(:,53) =rxt(:,123)*y(:,35) +rxt(:,124)*y(:,36) +rxt(:,126)*y(:,38) &
                  +2.000_r8*rxt(:,127)*y(:,39) +2.000_r8*rxt(:,128)*y(:,40) &
                  +rxt(:,129)*y(:,41) +2.000_r8*rxt(:,142)*y(:,80) +rxt(:,145)*y(:,85) &
                  +rxt(:,146)*y(:,86)
         prod(:,62) =rxt(:,125)*y(:,37) +rxt(:,126)*y(:,38) +rxt(:,144)*y(:,84)
         prod(:,64) = 0._r8
         prod(:,132) = 0._r8
         prod(:,81) = 0._r8
         prod(:,3) = 0._r8
         prod(:,4) = 0._r8
         prod(:,5) = 0._r8
         prod(:,51) = 0._r8
         prod(:,167) =rxt(:,124)*y(:,36) +rxt(:,128)*y(:,40)
         prod(:,218) = 0._r8
         prod(:,193) = 0._r8
         prod(:,271) = (rxt(:,38) +.330_r8*rxt(:,39))*y(:,55)
         prod(:,215) =1.440_r8*rxt(:,39)*y(:,55)
         prod(:,208) = 0._r8
         prod(:,52) = 0._r8
         prod(:,180) = 0._r8
         prod(:,283) = 0._r8
         prod(:,59) = 0._r8
         prod(:,149) = 0._r8
         prod(:,187) = 0._r8
         prod(:,68) = 0._r8
         prod(:,186) = 0._r8
         prod(:,270) = 0._r8
         prod(:,103) = 0._r8
         prod(:,168) = 0._r8
         prod(:,182) = 0._r8
         prod(:,165) = 0._r8
         prod(:,130) = 0._r8
         prod(:,131) = 0._r8
         prod(:,112) = 0._r8
         prod(:,113) = 0._r8
         prod(:,228) = 0._r8
         prod(:,234) = 0._r8
         prod(:,158) = 0._r8
         prod(:,198) = 0._r8
         prod(:,157) = 0._r8
         prod(:,111) = 0._r8
         prod(:,184) = 0._r8
         prod(:,202) = 0._r8
         prod(:,222) = 0._r8
         prod(:,178) = 0._r8
         prod(:,230) = 0._r8
         prod(:,206) = 0._r8
         prod(:,143) = 0._r8
         prod(:,243) = 0._r8
         prod(:,133) = 0._r8
         prod(:,120) = 0._r8
         prod(:,244) = 0._r8
         prod(:,139) = 0._r8
         prod(:,181) = 0._r8
         prod(:,216) = 0._r8
         prod(:,156) = 0._r8
         prod(:,242) = 0._r8
         prod(:,42) = 0._r8
         prod(:,172) = 0._r8
         prod(:,236) = 0._r8
         prod(:,229) = 0._r8
         prod(:,205) = 0._r8
         prod(:,116) = 0._r8
         prod(:,86) = 0._r8
         prod(:,108) = 0._r8
         prod(:,241) = 0._r8
         prod(:,238) = 0._r8
         prod(:,210) = 0._r8
         prod(:,148) = 0._r8
         prod(:,95) = + extfrc(:,16)
         prod(:,82) = 0._r8
         prod(:,245) = 0._r8
         prod(:,6) = 0._r8
         prod(:,7) = 0._r8
         prod(:,8) = 0._r8
         prod(:,47) = 0._r8
         prod(:,9) = 0._r8
         prod(:,272) = + extfrc(:,2)
         prod(:,281) = + extfrc(:,3)
         prod(:,274) = 0._r8
         prod(:,201) = 0._r8
         prod(:,207) = 0._r8
         prod(:,10) = + extfrc(:,12)
         prod(:,11) = + extfrc(:,13)
         prod(:,12) = 0._r8
         prod(:,13) = + extfrc(:,14)
         prod(:,280) =.180_r8*rxt(:,39)*y(:,55) +rxt(:,40)*y(:,64) + (rxt(:,5) + &
                 2.000_r8*rxt(:,6))
         prod(:,273) = 0._r8
         prod(:,88) = 0._r8
         prod(:,93) = 0._r8
         prod(:,60) = 0._r8
         prod(:,109) = 0._r8
         prod(:,54) = 0._r8
         prod(:,110) = 0._r8
         prod(:,58) = 0._r8
         prod(:,89) = 0._r8
         prod(:,14) = + extfrc(:,6)
         prod(:,15) = + extfrc(:,7)
         prod(:,121) = 0._r8
         prod(:,98) = 0._r8
         prod(:,117) = 0._r8
         prod(:,221) = 0._r8
         prod(:,191) = + extfrc(:,4)
         prod(:,75) = 0._r8
         prod(:,16) = + extfrc(:,8)
         prod(:,17) = + extfrc(:,1)
         prod(:,18) = 0._r8
         prod(:,19) = 0._r8
         prod(:,20) = 0._r8
         prod(:,21) = 0._r8
         prod(:,22) = 0._r8
         prod(:,23) = 0._r8
         prod(:,24) = 0._r8
         prod(:,25) = 0._r8
         prod(:,26) = 0._r8
         prod(:,27) = 0._r8
         prod(:,28) = 0._r8
         prod(:,29) = 0._r8
         prod(:,30) = 0._r8
         prod(:,31) = 0._r8
         prod(:,32) = 0._r8
         prod(:,33) = 0._r8
         prod(:,34) = 0._r8
         prod(:,35) = + extfrc(:,5)
         prod(:,65) = 0._r8
         prod(:,253) = 0._r8
         prod(:,107) = 0._r8
         prod(:,254) = 0._r8
         prod(:,192) = 0._r8
         prod(:,124) = 0._r8
         prod(:,231) = 0._r8
         prod(:,125) = 0._r8
         prod(:,126) = 0._r8
         prod(:,78) = 0._r8
         prod(:,79) = 0._r8
         prod(:,100) = 0._r8
         prod(:,92) = 0._r8
         prod(:,262) = 0._r8
         prod(:,261) = 0._r8
         prod(:,190) = 0._r8
         prod(:,164) = 0._r8
         prod(:,175) = 0._r8
         prod(:,166) = 0._r8
         prod(:,134) = 0._r8
         prod(:,179) = 0._r8
         prod(:,144) = 0._r8
         prod(:,217) = 0._r8
         prod(:,226) = 0._r8
         prod(:,213) = 0._r8
         prod(:,227) = 0._r8
         prod(:,135) = 0._r8
         prod(:,127) = 0._r8
         prod(:,138) = 0._r8
         prod(:,63) = 0._r8
         prod(:,66) = 0._r8
         prod(:,150) = 0._r8
         prod(:,67) = 0._r8
         prod(:,101) = 0._r8
         prod(:,118) = 0._r8
         prod(:,188) = 0._r8
         prod(:,250) = 0._r8
         prod(:,255) = 0._r8
         prod(:,36) = 0._r8
         prod(:,247) = 0._r8
         prod(:,249) = 0._r8
         prod(:,37) = 0._r8
         prod(:,114) = 0._r8
         prod(:,38) = 0._r8
         prod(:,259) = 0._r8
         prod(:,256) = 0._r8
         prod(:,39) = 0._r8
         prod(:,102) = 0._r8
         prod(:,199) = 0._r8
         prod(:,173) = 0._r8
         prod(:,137) = 0._r8
         prod(:,269) = 0._r8
         prod(:,279) =rxt(:,131)*y(:,44) +rxt(:,133)*y(:,47) +rxt(:,38)*y(:,55)
         prod(:,155) = 0._r8
         prod(:,129) = 0._r8
         prod(:,80) = 0._r8
         prod(:,151) = 0._r8
         prod(:,276) = 0._r8
         prod(:,136) = 0._r8
         prod(:,214) = 0._r8
         prod(:,239) = 0._r8
         prod(:,235) = 0._r8
         prod(:,71) = 0._r8
         prod(:,72) = 0._r8
         prod(:,73) = 0._r8
         prod(:,74) = 0._r8
         prod(:,224) = 0._r8
         prod(:,225) = 0._r8
         prod(:,176) = 0._r8
         prod(:,183) = 0._r8
         prod(:,174) = 0._r8
         prod(:,177) = 0._r8
         prod(:,204) = 0._r8
         prod(:,246) = 0._r8
         prod(:,194) = 0._r8
         prod(:,200) = 0._r8
         prod(:,40) = 0._r8
         prod(:,237) = 0._r8
         prod(:,232) = 0._r8
         prod(:,41) = 0._r8
         prod(:,258) = 0._r8
         prod(:,252) = 0._r8
         prod(:,43) = 0._r8
         prod(:,212) = 0._r8
         prod(:,152) = 0._r8
         prod(:,220) = 0._r8
         prod(:,159) = 0._r8
         prod(:,142) = 0._r8
         prod(:,211) = 0._r8
         prod(:,260) = 0._r8
         prod(:,257) = 0._r8
         prod(:,44) = 0._r8
         prod(:,219) = 0._r8
         prod(:,275) =rxt(:,12)*y(:,137) +rxt(:,5)
         prod(:,282) =.330_r8*rxt(:,39)*y(:,55) + extfrc(:,15)
         prod(:,105) = 0._r8
         prod(:,160) = 0._r8
         prod(:,197) = 0._r8
         prod(:,161) = 0._r8
         prod(:,169) = 0._r8
         prod(:,263) = 0._r8
         prod(:,266) = 0._r8
         prod(:,265) = 0._r8
         prod(:,267) = 0._r8
         prod(:,248) = 0._r8
         prod(:,264) = 0._r8
         prod(:,268) = 0._r8
         prod(:,145) = 0._r8
         prod(:,162) = 0._r8
         prod(:,189) = 0._r8
         prod(:,170) = 0._r8
         prod(:,146) = 0._r8
         prod(:,147) = 0._r8
         prod(:,153) = 0._r8
         prod(:,45) = 0._r8
         prod(:,154) = 0._r8
         prod(:,46) = 0._r8
         prod(:,115) = 0._r8
         prod(:,286) =.050_r8*rxt(:,39)*y(:,55)
      end if
      end subroutine indprd
      end module mo_indprd
