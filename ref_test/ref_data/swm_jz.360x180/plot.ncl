case_name = "swm_jz.360x180"

f = addfile(case_name + ".h0.nc", "r")

itime = 6

wks = gsn_open_wks("pdf", case_name)

res = True
res@gsnDraw = False
res@gsnFrame = False
res@gsnMaximize = True
res@cnFillOn = True
res@mpOutlineOn = False

plot = new((/4/), graphic)

plot(0) = gsn_csm_contour_map(wks, f->u (itime,:,:), res)
plot(1) = gsn_csm_contour_map(wks, f->v (itime,:,:), res)
plot(2) = gsn_csm_contour_map(wks, f->pv(itime,:,:), res)
plot(3) = gsn_csm_contour_map(wks, f->z (itime,:,:), res)

res := True
res@gsnMaximize = False
res@gsnPanelMainString = "Day: " + f->time(itime)
gsn_panel(wks, plot, (/2,2/), res)
