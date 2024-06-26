      module mo_lin_matrix
      use chem_mods, only: veclen
      private
      public :: linmat
      contains
      subroutine linmat01( avec_len, mat, y, rxt, het_rates )
!----------------------------------------------
! ... linear matrix entries for implicit species
!----------------------------------------------
      use chem_mods, only : gas_pcnst, rxntot, nzcnt
      use shr_kind_mod, only : r8 => shr_kind_r8
      implicit none
!----------------------------------------------
! ... dummy arguments
!----------------------------------------------
      integer, intent(in) :: avec_len
      real(r8), intent(in) :: y(veclen,gas_pcnst)
      real(r8), intent(in) :: rxt(veclen,rxntot)
      real(r8), intent(in) :: het_rates(veclen,gas_pcnst)
      real(r8), intent(inout) :: mat(veclen,nzcnt)
!----------------------------------------------
! ... local variables
!----------------------------------------------
      integer :: k
      do k = 1,avec_len
         mat(k,561) = -( rxt(k,19) + het_rates(k,1) )
         mat(k,537) = -( rxt(k,20) + het_rates(k,2) )
         mat(k,1) = -( het_rates(k,4) )
         mat(k,2) = -( het_rates(k,5) )
         mat(k,788) = -( het_rates(k,6) )
         mat(k,113) = -( het_rates(k,7) )
         mat(k,304) = -( rxt(k,21) + het_rates(k,8) )
         mat(k,119) = -( rxt(k,22) + het_rates(k,9) )
         mat(k,310) = -( rxt(k,23) + het_rates(k,10) )
         mat(k,379) = -( rxt(k,24) + het_rates(k,11) )
         mat(k,305) = .500_r8*rxt(k,21)
         mat(k,120) = rxt(k,22)
         mat(k,548) = .200_r8*rxt(k,70)
         mat(k,589) = .060_r8*rxt(k,72)
         mat(k,222) = -( rxt(k,25) + het_rates(k,12) )
         mat(k,547) = .200_r8*rxt(k,70)
         mat(k,587) = .200_r8*rxt(k,72)
         mat(k,493) = -( rxt(k,26) + het_rates(k,13) )
         mat(k,177) = rxt(k,46)
         mat(k,892) = rxt(k,56)
         mat(k,549) = .200_r8*rxt(k,70)
         mat(k,590) = .150_r8*rxt(k,72)
         mat(k,247) = -( rxt(k,27) + het_rates(k,14) )
         mat(k,588) = .210_r8*rxt(k,72)
         mat(k,184) = -( het_rates(k,15) )
         mat(k,284) = -( het_rates(k,16) )
         mat(k,1278) = -( het_rates(k,17) )
         mat(k,188) = rxt(k,74)
         mat(k,1707) = rxt(k,75)
         mat(k,451) = rxt(k,77)
         mat(k,705) = rxt(k,99)
         mat(k,669) = rxt(k,105)
         mat(k,1348) = rxt(k,200)*y(k,34) + rxt(k,226)*y(k,35) &
                      + 3.000_r8*rxt(k,227)*y(k,55) + 2.000_r8*rxt(k,228)*y(k,78) &
                      + 2.000_r8*rxt(k,249)*y(k,41) + rxt(k,250)*y(k,43)
         mat(k,1921) = 2.000_r8*rxt(k,237)*y(k,41) + rxt(k,239)*y(k,43) &
                      + 3.000_r8*rxt(k,244)*y(k,55)
         mat(k,1502) = 2.000_r8*rxt(k,238)*y(k,41) + rxt(k,240)*y(k,43) &
                      + 3.000_r8*rxt(k,245)*y(k,55)
         mat(k,187) = -( rxt(k,74) + het_rates(k,18) )
         mat(k,1716) = -( rxt(k,75) + het_rates(k,19) )
         mat(k,454) = rxt(k,76)
         mat(k,449) = -( rxt(k,76) + rxt(k,77) + rxt(k,524) + rxt(k,527) + rxt(k,532) &
                 + het_rates(k,20) )
         mat(k,190) = -( het_rates(k,22) )
         mat(k,262) = rxt(k,28)
         mat(k,263) = -( rxt(k,28) + het_rates(k,23) )
         mat(k,225) = -( het_rates(k,24) )
         mat(k,465) = -( het_rates(k,25) )
         mat(k,198) = -( het_rates(k,26) )
         mat(k,268) = -( rxt(k,29) + het_rates(k,27) )
         mat(k,231) = -( het_rates(k,28) )
         mat(k,869) = -( het_rates(k,29) )
         mat(k,1159) = .700_r8*rxt(k,55)
         mat(k,346) = -( rxt(k,30) + het_rates(k,30) )
         mat(k,93) = -( het_rates(k,31) )
         mat(k,202) = -( rxt(k,31) + het_rates(k,32) )
         mat(k,1739) = -( rxt(k,32) + rxt(k,33) + het_rates(k,42) )
         mat(k,569) = .100_r8*rxt(k,19)
         mat(k,545) = .100_r8*rxt(k,20)
         mat(k,326) = rxt(k,38)
         mat(k,911) = rxt(k,43)
         mat(k,926) = .330_r8*rxt(k,45)
         mat(k,947) = rxt(k,47)
         mat(k,585) = .690_r8*rxt(k,49)
         mat(k,1095) = 1.340_r8*rxt(k,50)
         mat(k,756) = rxt(k,57)
         mat(k,446) = rxt(k,62)
         mat(k,344) = rxt(k,63)
         mat(k,511) = .375_r8*rxt(k,65)
         mat(k,398) = .400_r8*rxt(k,67)
         mat(k,936) = .680_r8*rxt(k,69)
         mat(k,370) = rxt(k,269)
         mat(k,208) = 2.000_r8*rxt(k,299)
         mat(k,1358) = rxt(k,272)*y(k,54) + rxt(k,273)*y(k,54)
         mat(k,1024) = -( rxt(k,34) + het_rates(k,45) )
         mat(k,565) = .400_r8*rxt(k,19)
         mat(k,542) = .400_r8*rxt(k,20)
         mat(k,270) = rxt(k,29)
         mat(k,920) = .330_r8*rxt(k,45)
         mat(k,244) = rxt(k,53)
         mat(k,444) = rxt(k,62)
         mat(k,87) = -( het_rates(k,47) )
         mat(k,847) = -( rxt(k,35) + het_rates(k,48) )
         mat(k,564) = .250_r8*rxt(k,19)
         mat(k,541) = .250_r8*rxt(k,20)
         mat(k,348) = .820_r8*rxt(k,30)
         mat(k,914) = .170_r8*rxt(k,45)
         mat(k,505) = .300_r8*rxt(k,65)
         mat(k,394) = .050_r8*rxt(k,67)
         mat(k,929) = .500_r8*rxt(k,69)
         mat(k,1100) = -( rxt(k,36) + het_rates(k,49) )
         mat(k,313) = .180_r8*rxt(k,23)
         mat(k,249) = rxt(k,27)
         mat(k,557) = .400_r8*rxt(k,70)
         mat(k,598) = .540_r8*rxt(k,72)
         mat(k,355) = .510_r8*rxt(k,73)
         mat(k,473) = -( het_rates(k,50) )
         mat(k,435) = -( rxt(k,37) + het_rates(k,51) )
         mat(k,696) = -( het_rates(k,52) )
         mat(k,322) = -( rxt(k,38) + het_rates(k,53) )
         mat(k,1935) = -( rxt(k,175)*y(k,54) + rxt(k,237)*y(k,41) + rxt(k,239)*y(k,43) &
                      + rxt(k,242)*y(k,46) + rxt(k,244)*y(k,55) + het_rates(k,56) )
         mat(k,189) = rxt(k,74)
         mat(k,129) = 2.000_r8*rxt(k,91)
         mat(k,92) = 2.000_r8*rxt(k,92)
         mat(k,1338) = rxt(k,93)
         mat(k,862) = rxt(k,94)
         mat(k,137) = rxt(k,97)
         mat(k,1901) = rxt(k,103)
         mat(k,729) = rxt(k,106)
         mat(k,1362) = 4.000_r8*rxt(k,199)*y(k,33) + rxt(k,200)*y(k,34) &
                      + 2.000_r8*rxt(k,201)*y(k,36) + 2.000_r8*rxt(k,202)*y(k,37) &
                      + 2.000_r8*rxt(k,203)*y(k,38) + rxt(k,204)*y(k,39) &
                      + 2.000_r8*rxt(k,205)*y(k,40) + rxt(k,251)*y(k,82) &
                      + rxt(k,252)*y(k,83) + rxt(k,253)*y(k,84)
         mat(k,1516) = 3.000_r8*rxt(k,241)*y(k,44) + rxt(k,243)*y(k,46) &
                      + rxt(k,246)*y(k,82) + rxt(k,247)*y(k,83) + rxt(k,248)*y(k,84)
         mat(k,128) = -( rxt(k,91) + het_rates(k,57) )
         mat(k,90) = -( rxt(k,92) + rxt(k,209) + het_rates(k,58) )
         mat(k,1327) = -( rxt(k,93) + het_rates(k,59) )
         mat(k,857) = rxt(k,95)
         mat(k,255) = rxt(k,107)
         mat(k,91) = 2.000_r8*rxt(k,209)
         mat(k,855) = -( rxt(k,94) + rxt(k,95) + rxt(k,526) + rxt(k,531) + rxt(k,537) &
                 + het_rates(k,60) )
         mat(k,939) = -( het_rates(k,62) )
         mat(k,121) = 1.500_r8*rxt(k,22)
         mat(k,312) = .450_r8*rxt(k,23)
         mat(k,495) = .600_r8*rxt(k,26)
         mat(k,248) = rxt(k,27)
         mat(k,1728) = rxt(k,32) + rxt(k,33)
         mat(k,1023) = rxt(k,34)
         mat(k,1099) = rxt(k,36)
         mat(k,909) = rxt(k,43)
         mat(k,766) = 2.000_r8*rxt(k,44)
         mat(k,917) = .330_r8*rxt(k,45)
         mat(k,1087) = 1.340_r8*rxt(k,51)
         mat(k,1160) = .700_r8*rxt(k,55)
         mat(k,152) = 1.500_r8*rxt(k,64)
         mat(k,508) = .250_r8*rxt(k,65)
         mat(k,886) = rxt(k,68)
         mat(k,931) = 1.700_r8*rxt(k,69)
         mat(k,279) = rxt(k,110)
         mat(k,1917) = rxt(k,242)*y(k,46)
         mat(k,109) = -( rxt(k,96) + het_rates(k,64) )
         mat(k,1342) = rxt(k,200)*y(k,34) + rxt(k,202)*y(k,37) &
                      + 2.000_r8*rxt(k,203)*y(k,38) + 2.000_r8*rxt(k,204)*y(k,39) &
                      + rxt(k,205)*y(k,40) + rxt(k,226)*y(k,35) &
                      + 2.000_r8*rxt(k,228)*y(k,78) + rxt(k,252)*y(k,83) &
                      + rxt(k,253)*y(k,84)
         mat(k,1384) = rxt(k,247)*y(k,83) + rxt(k,248)*y(k,84)
         mat(k,134) = -( rxt(k,97) + het_rates(k,65) )
         mat(k,1344) = rxt(k,201)*y(k,36) + rxt(k,202)*y(k,37) + rxt(k,251)*y(k,82)
         mat(k,1389) = rxt(k,246)*y(k,82)
         mat(k,146) = -( het_rates(k,66) )
         mat(k,210) = -( het_rates(k,67) )
         mat(k,3) = -( het_rates(k,68) )
         mat(k,4) = -( het_rates(k,69) )
         mat(k,5) = -( het_rates(k,70) )
         mat(k,97) = -( rxt(k,42) + het_rates(k,72) )
         mat(k,677) = -( rxt(k,231)*y(k,54) + het_rates(k,73) )
         mat(k,110) = 2.000_r8*rxt(k,96)
         mat(k,135) = rxt(k,97)
         mat(k,174) = rxt(k,104)
         mat(k,1345) = rxt(k,204)*y(k,39) + rxt(k,226)*y(k,35)
         mat(k,908) = -( rxt(k,43) + het_rates(k,74) )
         mat(k,915) = .330_r8*rxt(k,45)
         mat(k,506) = .250_r8*rxt(k,65)
         mat(k,207) = rxt(k,300)
         mat(k,765) = -( rxt(k,44) + rxt(k,480) + het_rates(k,75) )
         mat(k,307) = rxt(k,21)
         mat(k,311) = .130_r8*rxt(k,23)
         mat(k,259) = .700_r8*rxt(k,61)
         mat(k,554) = .600_r8*rxt(k,70)
         mat(k,595) = .340_r8*rxt(k,72)
         mat(k,354) = .170_r8*rxt(k,73)
         mat(k,1304) = -( rxt(k,137) + het_rates(k,76) )
         mat(k,2065) = rxt(k,2) + 2.000_r8*rxt(k,3)
         mat(k,1732) = 2.000_r8*rxt(k,32)
         mat(k,323) = rxt(k,38)
         mat(k,706) = rxt(k,99)
         mat(k,1889) = rxt(k,103)
         mat(k,175) = rxt(k,104)
         mat(k,1350) = rxt(k,272)*y(k,54)
         mat(k,1035) = -( het_rates(k,77) )
         mat(k,2061) = rxt(k,1)
         mat(k,1729) = rxt(k,33)
         mat(k,1347) = rxt(k,273)*y(k,54)
         mat(k,497) = -( rxt(k,4) + het_rates(k,79) )
         mat(k,1788) = .500_r8*rxt(k,481)
         mat(k,100) = -( rxt(k,109) + het_rates(k,80) )
         mat(k,704) = -( rxt(k,99) + het_rates(k,81) )
         mat(k,1900) = -( rxt(k,103) + het_rates(k,85) )
         mat(k,1934) = rxt(k,175)*y(k,54) + rxt(k,237)*y(k,41) + rxt(k,239)*y(k,43) &
                      + 2.000_r8*rxt(k,242)*y(k,46) + rxt(k,244)*y(k,55)
         mat(k,130) = -( het_rates(k,86) )
         mat(k,700) = -( het_rates(k,87) )
         mat(k,173) = -( rxt(k,104) + het_rates(k,88) )
         mat(k,676) = rxt(k,231)*y(k,54)
         mat(k,1291) = -( rxt(k,9) + het_rates(k,89) )
         mat(k,922) = rxt(k,482)
         mat(k,517) = rxt(k,483)
         mat(k,462) = rxt(k,484)
         mat(k,217) = 2.000_r8*rxt(k,485) + 2.000_r8*rxt(k,522) + 2.000_r8*rxt(k,525) &
                      + 2.000_r8*rxt(k,536)
         mat(k,301) = rxt(k,486)
         mat(k,900) = rxt(k,487)
         mat(k,1544) = .500_r8*rxt(k,489)
         mat(k,1979) = rxt(k,490)
         mat(k,319) = rxt(k,491)
         mat(k,182) = rxt(k,492)
         mat(k,524) = rxt(k,493)
         mat(k,452) = rxt(k,524) + rxt(k,527) + rxt(k,532)
         mat(k,856) = rxt(k,526) + rxt(k,531) + rxt(k,537)
      end do
      end subroutine linmat01
      subroutine linmat02( avec_len, mat, y, rxt, het_rates )
!----------------------------------------------
! ... linear matrix entries for implicit species
!----------------------------------------------
      use chem_mods, only : gas_pcnst, rxntot, nzcnt
      use shr_kind_mod, only : r8 => shr_kind_r8
      implicit none
!----------------------------------------------
! ... dummy arguments
!----------------------------------------------
      integer, intent(in) :: avec_len
      real(r8), intent(in) :: y(veclen,gas_pcnst)
      real(r8), intent(in) :: rxt(veclen,rxntot)
      real(r8), intent(in) :: het_rates(veclen,gas_pcnst)
      real(r8), intent(inout) :: mat(veclen,nzcnt)
!----------------------------------------------
! ... local variables
!----------------------------------------------
      integer :: k
      do k = 1,avec_len
         mat(k,334) = -( rxt(k,10) + rxt(k,11) + rxt(k,172) + het_rates(k,90) )
         mat(k,668) = -( rxt(k,105) + het_rates(k,91) )
         mat(k,450) = rxt(k,524) + rxt(k,527) + rxt(k,532)
         mat(k,724) = -( rxt(k,106) + het_rates(k,92) )
         mat(k,854) = rxt(k,526) + rxt(k,531) + rxt(k,537)
         mat(k,916) = -( rxt(k,45) + rxt(k,482) + het_rates(k,93) )
         mat(k,176) = -( rxt(k,46) + het_rates(k,94) )
         mat(k,1124) = rxt(k,373)
         mat(k,943) = -( rxt(k,47) + het_rates(k,95) )
         mat(k,918) = .170_r8*rxt(k,45)
         mat(k,273) = -( het_rates(k,96) )
         mat(k,103) = -( het_rates(k,97) )
         mat(k,735) = -( het_rates(k,98) )
         mat(k,513) = -( rxt(k,483) + het_rates(k,99) )
         mat(k,457) = -( rxt(k,484) + het_rates(k,100) )
         mat(k,1072) = -( het_rates(k,101) )
         mat(k,328) = -( rxt(k,48) + het_rates(k,102) )
         mat(k,580) = -( rxt(k,49) + het_rates(k,103) )
         mat(k,329) = rxt(k,48)
         mat(k,65) = -( het_rates(k,104) )
         mat(k,1088) = -( rxt(k,50) + rxt(k,51) + het_rates(k,105) )
         mat(k,582) = .288_r8*rxt(k,49)
         mat(k,237) = -( het_rates(k,106) )
         mat(k,423) = -( rxt(k,52) + het_rates(k,107) )
         mat(k,560) = .800_r8*rxt(k,19)
         mat(k,536) = .800_r8*rxt(k,20)
         mat(k,242) = -( rxt(k,53) + het_rates(k,108) )
         mat(k,485) = -( rxt(k,54) + rxt(k,355) + het_rates(k,109) )
         mat(k,815) = -( het_rates(k,110) )
         mat(k,1164) = -( rxt(k,55) + het_rates(k,111) )
         mat(k,583) = .402_r8*rxt(k,49)
         mat(k,292) = -( rxt(k,154) + het_rates(k,112) )
         mat(k,1579) = rxt(k,15)
         mat(k,216) = -( rxt(k,13) + rxt(k,14) + rxt(k,173) + rxt(k,485) + rxt(k,522) &
                      + rxt(k,525) + rxt(k,536) + het_rates(k,114) )
         mat(k,298) = -( rxt(k,486) + het_rates(k,115) )
         mat(k,896) = -( rxt(k,56) + rxt(k,487) + het_rates(k,116) )
         mat(k,6) = -( het_rates(k,117) )
         mat(k,7) = -( het_rates(k,118) )
         mat(k,8) = -( het_rates(k,119) )
         mat(k,84) = -( het_rates(k,120) )
         mat(k,9) = -( rxt(k,488) + het_rates(k,121) )
         mat(k,1640) = -( rxt(k,15) + het_rates(k,124) )
         mat(k,219) = rxt(k,14)
         mat(k,1550) = rxt(k,16) + .500_r8*rxt(k,489)
         mat(k,1985) = rxt(k,17)
         mat(k,296) = rxt(k,154)
         mat(k,1355) = 2.000_r8*rxt(k,166)*y(k,113)
         mat(k,1549) = -( rxt(k,16) + rxt(k,489) + het_rates(k,125) )
         mat(k,1295) = rxt(k,9)
         mat(k,336) = rxt(k,11) + rxt(k,172)
         mat(k,218) = rxt(k,13) + rxt(k,173)
         mat(k,1984) = rxt(k,18)
         mat(k,568) = rxt(k,19)
         mat(k,924) = rxt(k,45)
         mat(k,332) = rxt(k,48)
         mat(k,489) = rxt(k,54) + rxt(k,355)
         mat(k,902) = rxt(k,56)
         mat(k,755) = rxt(k,57)
         mat(k,321) = rxt(k,58)
         mat(k,183) = rxt(k,59)
         mat(k,385) = .600_r8*rxt(k,60) + rxt(k,306)
         mat(k,526) = rxt(k,66)
         mat(k,453) = rxt(k,76)
         mat(k,859) = rxt(k,95)
         mat(k,108) = rxt(k,430)
         mat(k,1993) = -( rxt(k,17) + rxt(k,18) + rxt(k,490) + het_rates(k,126) )
         mat(k,338) = rxt(k,10)
         mat(k,221) = rxt(k,13) + rxt(k,14) + rxt(k,173)
         mat(k,388) = .400_r8*rxt(k,60)
         mat(k,456) = rxt(k,77)
         mat(k,863) = rxt(k,94)
         mat(k,751) = -( rxt(k,57) + het_rates(k,127) )
         mat(k,316) = -( rxt(k,58) + rxt(k,491) + het_rates(k,128) )
         mat(k,10) = -( het_rates(k,129) )
         mat(k,11) = -( het_rates(k,130) )
         mat(k,12) = -( het_rates(k,131) )
         mat(k,13) = -( het_rates(k,132) )
         mat(k,1876) = -( rxt(k,131) + het_rates(k,133) )
         mat(k,2075) = rxt(k,3)
         mat(k,2050) = rxt(k,8)
         mat(k,220) = rxt(k,14)
         mat(k,1645) = rxt(k,15)
         mat(k,1555) = rxt(k,16)
         mat(k,1990) = rxt(k,18)
         mat(k,1719) = rxt(k,75)
         mat(k,1336) = rxt(k,93)
         mat(k,256) = rxt(k,107)
         mat(k,1120) = rxt(k,111) + rxt(k,472)
         mat(k,762) = rxt(k,112)
         mat(k,196) = rxt(k,113)
         mat(k,1360) = rxt(k,126) + rxt(k,127)
         mat(k,297) = rxt(k,154)
         mat(k,421) = rxt(k,466)
         mat(k,2054) = -( rxt(k,7) + rxt(k,8) + het_rates(k,134) )
         mat(k,1880) = rxt(k,131)
         mat(k,252) = -( rxt(k,107) + het_rates(k,136) )
         mat(k,276) = -( rxt(k,110) + het_rates(k,137) )
         mat(k,181) = -( rxt(k,59) + rxt(k,492) + het_rates(k,138) )
         mat(k,382) = -( rxt(k,60) + rxt(k,306) + het_rates(k,139) )
         mat(k,106) = -( rxt(k,430) + het_rates(k,140) )
         mat(k,389) = -( het_rates(k,141) )
         mat(k,203) = rxt(k,31)
         mat(k,123) = -( het_rates(k,142) )
         mat(k,257) = -( rxt(k,61) + het_rates(k,143) )
         mat(k,14) = -( het_rates(k,144) )
         mat(k,15) = -( het_rates(k,145) )
         mat(k,441) = -( rxt(k,62) + het_rates(k,146) )
         mat(k,340) = -( rxt(k,63) + het_rates(k,147) )
         mat(k,417) = -( rxt(k,466) + het_rates(k,148) )
         mat(k,277) = rxt(k,110)
         mat(k,1109) = rxt(k,111)
         mat(k,1111) = -( rxt(k,111) + rxt(k,472) + het_rates(k,150) )
         mat(k,759) = rxt(k,112)
         mat(k,418) = rxt(k,466)
         mat(k,758) = -( rxt(k,112) + het_rates(k,151) )
         mat(k,195) = rxt(k,113)
         mat(k,1110) = rxt(k,472)
         mat(k,194) = -( rxt(k,113) + het_rates(k,152) )
         mat(k,101) = rxt(k,109)
         mat(k,16) = -( het_rates(k,153) )
         mat(k,17) = -( het_rates(k,154) )
         mat(k,18) = -( het_rates(k,155) )
         mat(k,19) = -( rxt(k,114) + het_rates(k,156) )
         mat(k,20) = -( rxt(k,115) + het_rates(k,157) )
         mat(k,21) = -( rxt(k,116) + het_rates(k,158) )
         mat(k,22) = -( rxt(k,117) + het_rates(k,159) )
         mat(k,23) = -( rxt(k,118) + het_rates(k,160) )
         mat(k,24) = -( rxt(k,119) + het_rates(k,161) )
         mat(k,25) = -( rxt(k,120) + het_rates(k,162) )
         mat(k,26) = -( rxt(k,121) + het_rates(k,163) )
         mat(k,27) = -( rxt(k,122) + het_rates(k,164) )
         mat(k,28) = -( rxt(k,123) + het_rates(k,165) )
         mat(k,29) = -( het_rates(k,166) )
         mat(k,764) = rxt(k,480)
         mat(k,30) = -( het_rates(k,167) )
         mat(k,31) = -( het_rates(k,168) )
         mat(k,32) = -( het_rates(k,169) )
         mat(k,33) = -( het_rates(k,170) )
         mat(k,39) = -( het_rates(k,172) )
         mat(k,151) = -( rxt(k,64) + het_rates(k,173) )
         mat(k,504) = -( rxt(k,65) + het_rates(k,174) )
         mat(k,522) = -( rxt(k,66) + rxt(k,493) + het_rates(k,175) )
         mat(k,393) = -( rxt(k,67) + het_rates(k,176) )
         mat(k,884) = -( rxt(k,68) + het_rates(k,177) )
         mat(k,317) = rxt(k,58)
         mat(k,523) = rxt(k,66)
         mat(k,395) = rxt(k,67)
         mat(k,930) = -( rxt(k,69) + het_rates(k,178) )
         mat(k,507) = rxt(k,65)
         mat(k,885) = rxt(k,68)
         mat(k,550) = -( rxt(k,70) + het_rates(k,179) )
         mat(k,139) = -( het_rates(k,180) )
         mat(k,155) = -( rxt(k,71) + het_rates(k,181) )
         mat(k,160) = -( het_rates(k,182) )
         mat(k,591) = -( rxt(k,72) + het_rates(k,183) )
         mat(k,168) = -( het_rates(k,184) )
         mat(k,352) = -( rxt(k,73) + het_rates(k,185) )
         mat(k,429) = -( het_rates(k,188) )
         mat(k,107) = rxt(k,430)
         mat(k,837) = -( het_rates(k,189) )
         mat(k,45) = -( het_rates(k,190) )
         mat(k,402) = -( het_rates(k,191) )
         mat(k,51) = -( het_rates(k,192) )
         mat(k,360) = -( het_rates(k,193) )
         mat(k,715) = -( het_rates(k,194) )
         mat(k,425) = rxt(k,52)
         mat(k,686) = -( het_rates(k,195) )
         mat(k,530) = -( het_rates(k,196) )
         mat(k,1264) = -( het_rates(k,197) )
         mat(k,314) = .130_r8*rxt(k,23)
         mat(k,250) = rxt(k,27)
         mat(k,849) = rxt(k,35)
         mat(k,1101) = rxt(k,36)
         mat(k,921) = .330_r8*rxt(k,45)
         mat(k,945) = rxt(k,47)
         mat(k,1092) = 1.340_r8*rxt(k,50)
         mat(k,426) = rxt(k,52)
         mat(k,245) = rxt(k,53)
         mat(k,1166) = .300_r8*rxt(k,55)
         mat(k,753) = rxt(k,57)
         mat(k,383) = .600_r8*rxt(k,60) + rxt(k,306)
         mat(k,342) = rxt(k,63)
         mat(k,153) = .500_r8*rxt(k,64)
         mat(k,933) = .650_r8*rxt(k,69)
         mat(k,1691) = -( het_rates(k,198) )
         mat(k,1029) = rxt(k,34)
         mat(k,851) = rxt(k,35)
         mat(k,438) = rxt(k,37)
         mat(k,1172) = .300_r8*rxt(k,55)
         mat(k,386) = .400_r8*rxt(k,60)
         mat(k,1929) = rxt(k,175)*y(k,54)
         mat(k,682) = rxt(k,231)*y(k,54)
         mat(k,1510) = rxt(k,264)*y(k,54)
         mat(k,1356) = rxt(k,271)*y(k,54)
         mat(k,649) = -( het_rates(k,199) )
         mat(k,223) = .600_r8*rxt(k,25)
         mat(k,477) = -( het_rates(k,200) )
         mat(k,206) = -( rxt(k,299) + rxt(k,300) + het_rates(k,201) )
         mat(k,98) = rxt(k,42)
         mat(k,604) = -( het_rates(k,202) )
      end do
      end subroutine linmat02
      subroutine linmat03( avec_len, mat, y, rxt, het_rates )
!----------------------------------------------
! ... linear matrix entries for implicit species
!----------------------------------------------
      use chem_mods, only : gas_pcnst, rxntot, nzcnt
      use shr_kind_mod, only : r8 => shr_kind_r8
      implicit none
!----------------------------------------------
! ... dummy arguments
!----------------------------------------------
      integer, intent(in) :: avec_len
      real(r8), intent(in) :: y(veclen,gas_pcnst)
      real(r8), intent(in) :: rxt(veclen,rxntot)
      real(r8), intent(in) :: het_rates(veclen,gas_pcnst)
      real(r8), intent(inout) :: mat(veclen,nzcnt)
!----------------------------------------------
! ... local variables
!----------------------------------------------
      integer :: k
      do k = 1,avec_len
         mat(k,1845) = -( rxt(k,481) + het_rates(k,203) )
         mat(k,337) = rxt(k,11) + rxt(k,172)
         mat(k,570) = rxt(k,19)
         mat(k,546) = .900_r8*rxt(k,20)
         mat(k,309) = rxt(k,21)
         mat(k,122) = 1.500_r8*rxt(k,22)
         mat(k,315) = .560_r8*rxt(k,23)
         mat(k,381) = rxt(k,24)
         mat(k,224) = .600_r8*rxt(k,25)
         mat(k,496) = .600_r8*rxt(k,26)
         mat(k,251) = rxt(k,27)
         mat(k,267) = rxt(k,28)
         mat(k,272) = rxt(k,29)
         mat(k,350) = rxt(k,30)
         mat(k,1030) = rxt(k,34)
         mat(k,1105) = rxt(k,36)
         mat(k,912) = 2.000_r8*rxt(k,43)
         mat(k,768) = 2.000_r8*rxt(k,44)
         mat(k,927) = .670_r8*rxt(k,45)
         mat(k,180) = rxt(k,46)
         mat(k,948) = rxt(k,47)
         mat(k,333) = rxt(k,48)
         mat(k,586) = rxt(k,49)
         mat(k,1096) = 1.340_r8*rxt(k,50) + .660_r8*rxt(k,51)
         mat(k,906) = rxt(k,56)
         mat(k,261) = rxt(k,61)
         mat(k,447) = rxt(k,62)
         mat(k,154) = rxt(k,64)
         mat(k,512) = rxt(k,65)
         mat(k,527) = rxt(k,66)
         mat(k,399) = rxt(k,67)
         mat(k,890) = rxt(k,68)
         mat(k,937) = 1.200_r8*rxt(k,69)
         mat(k,559) = rxt(k,70)
         mat(k,601) = rxt(k,72)
         mat(k,357) = rxt(k,73)
         mat(k,1309) = rxt(k,137)
         mat(k,371) = rxt(k,269)
         mat(k,209) = rxt(k,299) + rxt(k,300)
         mat(k,1154) = rxt(k,373)
         mat(k,1932) = rxt(k,239)*y(k,43) + rxt(k,242)*y(k,46)
         mat(k,1513) = rxt(k,240)*y(k,43) + rxt(k,243)*y(k,46)
         mat(k,1359) = rxt(k,272)*y(k,54)
         mat(k,366) = -( rxt(k,269) + het_rates(k,204) )
         mat(k,1214) = -( het_rates(k,205) )
         mat(k,1142) = -( rxt(k,373) + het_rates(k,206) )
         mat(k,57) = -( het_rates(k,207) )
         mat(k,63) = -( het_rates(k,208) )
         mat(k,1187) = -( het_rates(k,209) )
         mat(k,611) = -( het_rates(k,210) )
         mat(k,380) = .600_r8*rxt(k,24)
         mat(k,1233) = -( het_rates(k,211) )
         mat(k,1091) = .660_r8*rxt(k,50)
         mat(k,487) = rxt(k,54) + rxt(k,355)
         mat(k,770) = -( het_rates(k,212) )
         mat(k,494) = .600_r8*rxt(k,26)
         mat(k,572) = -( het_rates(k,213) )
         mat(k,71) = -( het_rates(k,214) )
         mat(k,997) = -( het_rates(k,215) )
         mat(k,1352) = -( rxt(k,126) + rxt(k,127) + rxt(k,166)*y(k,113) &
                      + rxt(k,167)*y(k,113) + rxt(k,199)*y(k,33) + rxt(k,200)*y(k,34) &
                      + rxt(k,201)*y(k,36) + rxt(k,202)*y(k,37) + rxt(k,203)*y(k,38) &
                      + rxt(k,204)*y(k,39) + rxt(k,205)*y(k,40) + rxt(k,226)*y(k,35) &
                      + rxt(k,227)*y(k,55) + rxt(k,228)*y(k,78) + rxt(k,249)*y(k,41) &
                      + rxt(k,250)*y(k,43) + rxt(k,251)*y(k,82) + rxt(k,252)*y(k,83) &
                      + rxt(k,253)*y(k,84) + rxt(k,271)*y(k,54) + rxt(k,272)*y(k,54) &
                      + rxt(k,273)*y(k,54) + het_rates(k,216) )
         mat(k,2067) = rxt(k,1)
         mat(k,2042) = rxt(k,7)
         mat(k,1507) = -( rxt(k,238)*y(k,41) + rxt(k,240)*y(k,43) + rxt(k,241)*y(k,44) &
                      + rxt(k,243)*y(k,46) + rxt(k,245)*y(k,55) + rxt(k,246)*y(k,82) &
                      + rxt(k,247)*y(k,83) + rxt(k,248)*y(k,84) + rxt(k,264)*y(k,54) &
                 + het_rates(k,217) )
         mat(k,2068) = rxt(k,2)
         mat(k,498) = 2.000_r8*rxt(k,4)
         mat(k,1294) = rxt(k,9)
         mat(k,335) = rxt(k,10)
         mat(k,544) = rxt(k,20)
         mat(k,308) = rxt(k,21)
         mat(k,266) = rxt(k,28)
         mat(k,271) = rxt(k,29)
         mat(k,349) = rxt(k,30)
         mat(k,205) = rxt(k,31)
         mat(k,437) = rxt(k,37)
         mat(k,324) = rxt(k,38)
         mat(k,99) = rxt(k,42)
         mat(k,179) = rxt(k,46)
         mat(k,246) = rxt(k,53)
         mat(k,320) = rxt(k,58)
         mat(k,260) = rxt(k,61)
         mat(k,445) = rxt(k,62)
         mat(k,343) = rxt(k,63)
         mat(k,510) = rxt(k,65)
         mat(k,397) = rxt(k,67)
         mat(k,558) = rxt(k,70)
         mat(k,157) = rxt(k,71)
         mat(k,600) = rxt(k,72)
         mat(k,356) = rxt(k,73)
         mat(k,670) = rxt(k,105)
         mat(k,726) = rxt(k,106)
         mat(k,1548) = .500_r8*rxt(k,489)
         mat(k,1353) = rxt(k,271)*y(k,54)
         mat(k,373) = -( het_rates(k,218) )
         mat(k,658) = -( het_rates(k,219) )
         mat(k,1013) = -( het_rates(k,220) )
         mat(k,932) = .150_r8*rxt(k,69)
         mat(k,978) = -( het_rates(k,221) )
         mat(k,956) = -( het_rates(k,222) )
         mat(k,622) = -( het_rates(k,223) )
         mat(k,77) = -( het_rates(k,224) )
         mat(k,1052) = -( het_rates(k,225) )
         mat(k,638) = -( het_rates(k,226) )
         mat(k,83) = -( het_rates(k,227) )
         mat(k,410) = -( het_rates(k,228) )
         mat(k,2080) = -( rxt(k,1) + rxt(k,2) + rxt(k,3) + het_rates(k,229) )
         mat(k,102) = rxt(k,109)
         mat(k,1519) = rxt(k,238)*y(k,41) + rxt(k,240)*y(k,43) + rxt(k,241)*y(k,44) &
                      + rxt(k,243)*y(k,46) + rxt(k,248)*y(k,84) + rxt(k,264)*y(k,54)
      end do
      end subroutine linmat03
      subroutine linmat( avec_len, mat, y, rxt, het_rates )
!----------------------------------------------
! ... linear matrix entries for implicit species
!----------------------------------------------
      use chem_mods, only : gas_pcnst, rxntot, nzcnt
      use shr_kind_mod, only : r8 => shr_kind_r8
      implicit none
!----------------------------------------------
! ... dummy arguments
!----------------------------------------------
      integer, intent(in) :: avec_len
      real(r8), intent(in) :: y(veclen,gas_pcnst)
      real(r8), intent(in) :: rxt(veclen,rxntot)
      real(r8), intent(in) :: het_rates(veclen,gas_pcnst)
      real(r8), intent(inout) :: mat(veclen,nzcnt)
      call linmat01( avec_len, mat, y, rxt, het_rates )
      call linmat02( avec_len, mat, y, rxt, het_rates )
      call linmat03( avec_len, mat, y, rxt, het_rates )
      end subroutine linmat
      end module mo_lin_matrix
