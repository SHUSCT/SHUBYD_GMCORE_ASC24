import netCDF4 as nc
import sys
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('-e', type=int, default=1, help='默认消除极小误差，=2时全部计算')
parser.add_argument('-p', default=0,help='测试文件')
parser.add_argument('-n', help='测试规模')
parser.add_argument('-debug',default=0, help='输出每个参数的比对结果,debug = 1时输出，默认为0')
args = parser.parse_args()

def Check():
    pass

def test(file_ref, file_test,m):
    #file_ref = './ref_data/adv_dcmip12.360x180/adv_dcmip12.360x180x60.h0.nc'  #标准答案路径
    #file_test = './ref_data/adv_dcmip12.360x180/adv_dcmip12.360x180x60.h0.nc' #测试结果路径
    dataset_ref = nc.Dataset(file_ref)
    dataset_test = nc.Dataset(file_test)

    if 'adv_dc4' in file_ref:
        flag = True
        z_ref = dataset_ref.variables['z']
        q0_ref = dataset_ref.variables['q0']
        q1_ref = dataset_ref.variables['q1']
        q2_ref = dataset_ref.variables['q2']
        q3_ref = dataset_ref.variables['q3']
        z_test = dataset_test.variables['z']
        q0_test = dataset_test.variables['q0']
        q1_test = dataset_test.variables['q1']
        q2_test = dataset_test.variables['q2']
        q3_test = dataset_test.variables['q3']
        lon = z_ref.shape[3]
        lat = z_ref.shape[2]
        time = z_ref.shape[0]
        lev = z_ref.shape[1]
        print(time, lev, lon, lat)
        #z:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon, 30):
                    for la in range(0, lat, 30):
                        item += 1
                        if z_ref[t, le, la, lo] == 0:
                            sumref += z_test[t, le, la, lo]
                        else:
                            sumref += abs((z_ref[t, le, la, lo] - z_test[t, le, la, lo]) / z_ref[t, le, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            print('wrong!!!z:', sumref / item)
            flag = False
        if m != 0:
            print('z:', sumref / item)
        #q0:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q0_ref[t, le, la, lo] == 0:
                            sumref += q0_test[t, le, la, lo]
                        else:
                            sumref += abs((q0_ref[t, le, la, lo] - q0_test[t, le, la, lo]) / q0_ref[t, le, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q0:', sumref / item)
        if m != 0:
            print('q0:', sumref / item)
        #q1:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q1_ref[t, le, la, lo] == 0:
                            sumref += q1_test[t, le, la, lo]
                        else:
                            sumref += abs((q1_ref[t, le, la, lo] - q1_test[t, le, la, lo]) / q1_ref[t, le, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q1:', sumref / item)
        if m != 0:
            print('q1:', sumref / item)
        #q2:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q2_ref[t, le, la, lo] == 0:
                            sumref += q2_test[t, le, la, lo]
                        else:
                            sumref += abs((q2_ref[t, le, la, lo] - q2_test[t, le, la, lo]) / q2_ref[t, le, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q2:', sumref / item)
        if m != 0:
            print('q2:', sumref / item)
        #q3:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q3_ref[t, le, la, lo] == 0:
                            sumref += q3_test[t, le, la, lo]
                        else:
                            sumref += abs((q3_ref[t, le, la, lo] - q3_test[t, le, la, lo]) / q3_ref[t, le, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q3:', sumref / item)
        if m != 0:
            print('q3:', sumref / item)
        if flag == True:
            print(file_test + ': right')
        else:
            print(file_test + ': wrong')

    elif 'adv' in file_ref:
        flag = True
        z_ref = dataset_ref.variables['z']
        q0_ref = dataset_ref.variables['q0']
        q1_ref = dataset_ref.variables['q1']
        z_test = dataset_test.variables['z']
        q0_test = dataset_test.variables['q0']
        q1_test = dataset_test.variables['q1']
        lon = z_ref.shape[3]
        lat = z_ref.shape[2]
        time = z_ref.shape[0]
        lev = z_ref.shape[1]
        print(time, lev, lon, lat)
        #z:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon, 30):
                    for la in range(0, lat, 30):
                        item += 1
                        if z_ref[t, le, la, lo] == 0:
                            sumref += z_test[t, le, la, lo]
                        else:
                            sumref += abs((z_ref[t, le, la, lo] - z_test[t, le, la, lo]) / z_ref[t, le, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!z:', sumref / item)
        if m != 0:
            print('z:', sumref / item)
        #q0:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q0_ref[t, le, la, lo] == 0:
                            sumref += q0_test[t, le, la, lo]
                        else:
                            sumref += abs((q0_ref[t, le, la, lo] - q0_test[t, le, la, lo]) / q0_ref[t, le, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q0:', sumref / item)
        if m != 0:
            print('q0:', sumref / item)
        #q1:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q1_ref[t, le, la, lo] == 0:
                            sumref += q1_test[t, le, la, lo]
                        else:
                            sumref += abs((q1_ref[t, le, la, lo] - q1_test[t, le, la, lo]) / q1_ref[t, le, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q1:', sumref / item)
        if m != 0:
            print('q1:', sumref / item)
        if flag == True:
            print(file_test + ': right')
        else:
            print(file_test + ': wrong')


    elif 'swm' in file_ref:
        flag = True
        tm_ref = dataset_ref.variables['tm']#101  time
        te_ref = dataset_ref.variables['te']#101 time
        tpe_ref = dataset_ref.variables['tpe']#101 time
        u_ref = dataset_ref.variables['u']#time lat lon
        v_ref = dataset_ref.variables['v']#time lat lon
        z_ref = dataset_ref.variables['z']#time lat lon
        pv_ref = dataset_ref.variables['pv']#time ilat ilon
        div_ref = dataset_ref.variables['div']#time lat lon
        zs_ref = dataset_ref.variables['zs']#lat lon
        tm_test = dataset_test.variables['tm']#101  time
        te_test = dataset_test.variables['te']#101 time
        tpe_test = dataset_test.variables['tpe']#101 time
        u_test = dataset_test.variables['u']#time lat lon
        v_test = dataset_test.variables['v']#time lat lon
        z_test = dataset_test.variables['z']#time lat lon
        pv_test = dataset_test.variables['pv']#time ilat ilon
        div_test = dataset_test.variables['div']#time lat lon
        zs_test = dataset_test.variables['zs']#lat lon
        lon = u_ref.shape[2]
        lat = u_ref.shape[1]
        time = tm_ref.shape[0]
        ilat = pv_ref.shape[1]
        print(time, lon, lat, ilat)
        #tm:
        item = 0
        sumref = 0
        for t in range(time):
            item += 1
            if tm_ref[t] == 0:
                sumref += tm_test[t]
            else:
                sumref += abs((tm_ref[t] - tm_test[t]) / tm_ref[t])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!tm:', sumref / item)
        if m != 0:
            print('tm:', sumref / item)
        #te:
        item = 0
        sumref = 0
        for t in range(time):
            item += 1
            if te_ref[t] == 0:
                sumref += te_test[t]
            else:
                sumref += abs((te_ref[t] - te_test[t]) / te_ref[t])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!te:', sumref / item)
        if m != 0:
            print('te:', sumref / item)
        #tpe:
        item = 0
        sumref = 0
        for t in range(time):
            item += 1
            if tpe_ref[t] == 0:
                sumref += tpe_test[t]
            else:
                sumref += abs((tpe_ref[t] - tpe_test[t]) / tpe_ref[t])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!tpe:', sumref / item)
        if m != 0:
            print('tpe:', sumref / item)
        #u:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for la in range(0, lat, 30):
                    item += 1
                    if u_ref[t, la, lo] == 0:
                        sumref += u_test[t, la, lo]
                    else:
                        sumref += abs((u_ref[t, la, lo] - u_test[t, la, lo]) / u_ref[t, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!u:', sumref / item)
        if m != 0:
            print('u:', sumref / item)
        #v:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for la in range(0, lat, 30):
                    item += 1
                    if v_ref[t, la, lo] == 0:
                        sumref += v_test[t, la, lo]
                    else:
                        sumref += abs((v_ref[t, la, lo] - v_test[t, la, lo]) / v_ref[t, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!v:', sumref / item)
        if m != 0:
            print('v:', sumref / item)
        #z:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for la in range(0, lat, 30):
                    item += 1
                    if z_ref[t, la, lo] == 0:
                        sumref += z_test[t, la, lo]
                    else:
                        sumref += abs((z_ref[t, la, lo] - z_test[t, la, lo]) / z_ref[t, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!z:', sumref / item)
        if m != 0:
            print('z:', sumref / item)
        #pv:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for ila in range(0, ilat, 30):
                    item += 1
                    if pv_ref[t, ila, lo] == 0:
                        sumref += pv_test[t, ila, lo]
                    else:
                        sumref += abs((pv_ref[t, ila, lo] - pv_test[t, ila, lo]) / pv_ref[t, ila, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!pv:', sumref / item)
        if m != 0:
            print('pv:', sumref / item)
        #div:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for la in range(0, lat, 30):
                    item += 1
                    if div_ref[t, la, lo] == 0:
                        sumref += div_test[t, la, lo]
                    else:
                        sumref += abs((div_ref[t, la, lo] - div_test[t, la, lo]) / div_ref[t, la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!div:', sumref / item)
        if m != 0:
            print('div:', sumref / item)
        #zs:
        item = 0
        sumref = 0
        for lo in range(0, lon, 30):
            for la in range(0, lat, 30):
                item += 1
                if zs_ref[la, lo] == 0:
                    sumref += zs_test[la, lo]
                else:
                    sumref += abs((zs_ref[la, lo] - zs_test[la, lo]) / zs_ref[la, lo])
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!zs:', sumref / item)

        if flag == True:
            print(file_test + ': right')
        else:
            print(file_test + ': wrong')
        if m != 0:
            print('zs:', sumref / item)
    else:
        print("This case doesn't surport now!")
    """
    elif 'rh' in file_ref:
        flag = True

        if flag == True:
            print('right')
        else:
            print('wrong')
    elif 'mz' in file_ref:
        flag = True

        if flag == True:
            print('right')
        else:
            print('wrong')
    elif 'bw' in file_ref:
        flag = True

        if flag == True:
            print('right')
        else:
            print('wrong')

    """

def test_eli(file_ref, file_test,mode):
    #file_ref = './ref_data/adv_dcmip12.360x180/adv_dcmip12.360x180x60.h0.nc'  #标准答案路径
    #file_test = './ref_data/adv_dcmip12.360x180/adv_dcmip12.360x180x60.h0.nc' #测试结果路径
    dataset_ref = nc.Dataset(file_ref)
    dataset_test = nc.Dataset(file_test)

    if 'adv_dc4' in file_ref:
        flag = True
        z_ref = dataset_ref.variables['z']
        q0_ref = dataset_ref.variables['q0']
        q1_ref = dataset_ref.variables['q1']
        q2_ref = dataset_ref.variables['q2']
        q3_ref = dataset_ref.variables['q3']
        z_test = dataset_test.variables['z']
        q0_test = dataset_test.variables['q0']
        q1_test = dataset_test.variables['q1']
        q2_test = dataset_test.variables['q2']
        q3_test = dataset_test.variables['q3']
        lon = z_ref.shape[3]
        lat = z_ref.shape[2]
        time = z_ref.shape[0]
        lev = z_ref.shape[1]
        print(time, lev, lon, lat)
        #z:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon, 30):
                    for la in range(0, lat, 30):
                        item += 1
                        if z_ref[t, le, la, lo] == 0:
                            sumref += z_test[t, le, la, lo]
                        else:
                            temp = abs((z_ref[t, le, la, lo] - z_test[t, le, la, lo]) )
                            if temp > 1e-16:
                                sumref += temp/ z_ref[t, le, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            print('wrong!!!z:', sumref / item)
            flag = False
        if m != 0:
            print('z:', sumref / item)
        #q0:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q0_ref[t, le, la, lo] == 0:
                            sumref += q0_test[t, le, la, lo]
                        else:
                            temp = abs((q0_ref[t, le, la, lo] - q0_test[t, le, la, lo]) )
                            if temp > 1e-16:
                                sumref += temp/ q0_ref[t, le, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q0:', sumref / item)
        if m != 0:
            print('q0:', sumref / item)
        #q1:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q1_ref[t, le, la, lo] == 0:
                            sumref += q1_test[t, le, la, lo]
                        else:
                            temp = abs((q1_ref[t, le, la, lo] - q1_test[t, le, la, lo]) )
                            if temp > 1e-16:
                                sumref += temp
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q1:', sumref / item)
        if m != 0:
            print('q1:', sumref / item)
        #q2:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q2_ref[t, le, la, lo] == 0:
                            sumref += q2_test[t, le, la, lo]
                        else:
                            temp = abs((q2_ref[t, le, la, lo] - q2_test[t, le, la, lo]))
                            if temp > 1e-16:
                                sumref += temp / q2_ref[t, le, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q2:', sumref / item)
        if m != 0:
            print('q2:', sumref / item)
        #q3:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q3_ref[t, le, la, lo] == 0:
                            sumref += q3_test[t, le, la, lo]
                        else:
                            temp = abs((q3_ref[t, le, la, lo] - q3_test[t, le, la, lo]))
                            if temp > 1e-16:
                                sumref += temp / q3_ref[t, le, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q3:', sumref / item)
        if m != 0:
            print('q3:', sumref / item)
        if flag == True:
            print(file_test + ': right')
        else:
            print(file_test + ': wrong')

    elif 'adv' in file_ref:
        flag = True
        z_ref = dataset_ref.variables['z']
        q0_ref = dataset_ref.variables['q0']
        q1_ref = dataset_ref.variables['q1']
        z_test = dataset_test.variables['z']
        q0_test = dataset_test.variables['q0']
        q1_test = dataset_test.variables['q1']
        lon = z_ref.shape[3]
        lat = z_ref.shape[2]
        time = z_ref.shape[0]
        lev = z_ref.shape[1]
        print(time, lev, lon, lat)
        #z:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon, 30):
                    for la in range(0, lat, 30):
                        item += 1
                        if z_ref[t, le, la, lo] == 0:
                            sumref += z_test[t, le, la, lo]
                        else:
                            temp = abs((z_ref[t, le, la, lo] - z_test[t, le, la, lo]) )
                            if temp > 1e-16:
                                sumref += temp/ z_ref[t, le, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!z:', sumref / item)
        if m != 0:
            print('z:', sumref / item)
        #q0:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q0_ref[t, le, la, lo] == 0:
                            sumref += q0_test[t, le, la, lo]
                        else:
                            temp = abs((q0_ref[t, le, la, lo] - q0_test[t, le, la, lo]) )
                            if temp > 1e-16:
                                sumref += temp/ q0_ref[t, le, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q0:', sumref / item)
        if m != 0:
            print('q0:', sumref / item)
        #q1:
        item = 0
        sumref = 0
        for t in range(time):
            for le in range(lev):
                for lo in range(0, lon,30):
                    for la in range(0, lat, 30):
                        item += 1
                        if q1_ref[t, le, la, lo] == 0:
                            sumref += q1_test[t, le, la, lo]
                        else:
                            temp =  abs((q1_ref[t, le, la, lo] - q1_test[t, le, la, lo]) )
                            if temp > 1e-16:
                                sumref += temp/ q1_ref[t, le, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!q1:', sumref / item)
        if m != 0:
            print('q1:', sumref / item)
        if flag == True:
            print(file_test + ': right')
        else:
            print(file_test + ': wrong')


    elif 'swm' in file_ref:
        flag = True
        tm_ref = dataset_ref.variables['tm']#101  time
        te_ref = dataset_ref.variables['te']#101 time
        tpe_ref = dataset_ref.variables['tpe']#101 time
        u_ref = dataset_ref.variables['u']#time lat lon
        v_ref = dataset_ref.variables['v']#time lat lon
        z_ref = dataset_ref.variables['z']#time lat lon
        pv_ref = dataset_ref.variables['pv']#time ilat ilon
        div_ref = dataset_ref.variables['div']#time lat lon
        zs_ref = dataset_ref.variables['zs']#lat lon
        tm_test = dataset_test.variables['tm']#101  time
        te_test = dataset_test.variables['te']#101 time
        tpe_test = dataset_test.variables['tpe']#101 time
        u_test = dataset_test.variables['u']#time lat lon
        v_test = dataset_test.variables['v']#time lat lon
        z_test = dataset_test.variables['z']#time lat lon
        pv_test = dataset_test.variables['pv']#time ilat ilon
        div_test = dataset_test.variables['div']#time lat lon
        zs_test = dataset_test.variables['zs']#lat lon
        lon = u_ref.shape[2]
        lat = u_ref.shape[1]
        time = tm_ref.shape[0]
        ilat = pv_ref.shape[1]
        print(time, lon, lat, ilat)
        #tm:
        item = 0
        sumref = 0
        for t in range(time):
            item += 1
            if tm_ref[t] == 0:
                sumref += tm_test[t]
            else:
                temp =  abs((tm_ref[t] - tm_test[t]))
                if temp > 1e-16:
                    sumref += temp / tm_ref[t]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!tm:', sumref / item)
        if m != 0:
            print('tm:', sumref / item)
        #te:
        item = 0
        sumref = 0
        for t in range(time):
            item += 1
            if te_ref[t] == 0:
                sumref += te_test[t]
            else:
                temp =  abs((te_ref[t] - te_test[t]) )
                if temp > 1e-16:
                    sumref += temp/ te_ref[t]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!te:', sumref / item)
        if m != 0:
            print('te:', sumref / item)
        #tpe:
        item = 0
        sumref = 0
        for t in range(time):
            item += 1
            if tpe_ref[t] == 0:
                sumref += tpe_test[t]
            else:
                temp =  abs((tpe_ref[t] - tpe_test[t]))
                if temp > 1e-16:
                    sumref += temp / tpe_ref[t]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!tpe:', sumref / item)
        if m != 0:
            print('tpe:', sumref / item)
        #u:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for la in range(0, lat, 30):
                    item += 1
                    if u_ref[t, la, lo] == 0:
                        sumref += u_test[t, la, lo]
                    else:
                        temp =  abs((u_ref[t, la, lo] - u_test[t, la, lo]) )
                        if temp > 1e-16:
                            sumref += temp/ u_ref[t, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!u:', sumref / item)
        if m != 0:
            print('u:', sumref / item)
        #v:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for la in range(0, lat, 30):
                    item += 1
                    if v_ref[t, la, lo] == 0:
                        sumref += v_test[t, la, lo]
                    else:
                        temp =  abs((v_ref[t, la, lo] - v_test[t, la, lo]) )
                        if temp > 1e-16:
                            sumref += temp/ v_ref[t, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!v:', sumref / item)
        if m != 0:
            print('v:', sumref / item)
        #z:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for la in range(0, lat, 30):
                    item += 1
                    if z_ref[t, la, lo] == 0:
                        sumref += z_test[t, la, lo]
                    else:
                        temp =  abs((z_ref[t, la, lo] - z_test[t, la, lo]) )
                        if temp > 1e-16:
                            sumref += temp/ z_ref[t, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!z:', sumref / item)
        if m != 0:
            print('z:', sumref / item)
        #pv:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for ila in range(0, ilat, 30):
                    item += 1
                    if pv_ref[t, ila, lo] == 0:
                        sumref += pv_test[t, ila, lo]
                    else:
                        temp =  abs((pv_ref[t, ila, lo] - pv_test[t, ila, lo]) )
                        if temp > 1e-16:
                            sumref += temp/ pv_ref[t, ila, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!pv:', sumref / item)
        if m != 0:
            print('pv:', sumref / item)
        #div:
        item = 0
        sumref = 0
        for t in range(time):
            for lo in range(0, lon, 30):
                for la in range(0, lat, 30):
                    item += 1
                    if div_ref[t, la, lo] == 0:
                        sumref += div_test[t, la, lo]
                    else:
                        temp =  abs((div_ref[t, la, lo] - div_test[t, la, lo]) )
                        if temp > 1e-16:
                            sumref += temp/ div_ref[t, la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!div:', sumref / item)
        if m != 0:
            print('div:', sumref / item)
        #zs:
        item = 0
        sumref = 0
        for lo in range(0, lon, 30):
            for la in range(0, lat, 30):
                item += 1
                if zs_ref[la, lo] == 0:
                    sumref += zs_test[la, lo]
                else:
                    temp = abs((zs_ref[la, lo] - zs_test[la, lo]) )
                    if temp > 1e-16:
                        sumref += temp/ zs_ref[la, lo]
        if sumref / item < 0.01:
            if flag == True:
                flag = True
        else:
            flag = False
            print('wrong!!!zs:', sumref / item)
        if m != 0:
            print('zs:', sumref / item)

        if flag == True:
            print(file_test + ': right')
        else:
            print(file_test + ': wrong')
    else:
        print("This case doesn't surport now!")
    """
    elif 'rh' in file_ref:
        flag = True

        if flag == True:
            print('right')
        else:
            print('wrong')
    elif 'mz' in file_ref:
        flag = True

        if flag == True:
            print('right')
        else:
            print('wrong')
    elif 'bw' in file_ref:
        flag = True

        if flag == True:
            print('right')
        else:
            print('wrong')

    """


if __name__ == "__main__":
    folder_path = '.' #这里请放置test_bed的路径，也就是说这个路径名以test_bed结束
    
    file_list = {'adv_sr.360x180' : 'adv_sr.360x180.h0.nc', 'adv_mv.360x180' : 'adv_mv.360x180.h0.nc', 'adv_dc4.360x180':'adv_dc4.360x180.h0.nc', \
        'adv_dcmip12.360x180': 'adv_dcmip12.360x180x60.h0.nc', 'swm_rh.180x90': 'swm_rh.180x90.h0.nc', 'swm_rh.360x180' : 'swm_rh.360x180.h0.nc', \
        'swm_mz.180x90' : 'swm_mz.180x90.h0.nc', 'swm_mz.360x180' : 'swm_mz.360x180.h0.nc', 'swm_jz.180x90' : 'swm_jz.180x90.h0.nc', \
        'swm_jz.360x180': 'swm_jz.360x180.h0.nc'}
    
    if (args.e == 2):
        func = test
    else:
        func = test_eli
    if args.p != 0:
        test_case = args.p + '.' + args.n
        if test_case in file_list.keys():
            ref_file = './ref_test/ref_data/' + test_case + '/' + file_list[test_case]
            test_file = folder_path + '/' + test_case + '/' + file_list[test_case]
            func(ref_file, test_file, args.debug)
            print('Done!')
        else:
            print("文件名参数传递错误！")
    else:
        for file in file_list:
            ref_file = './ref_data/' + file + '/' + file_list[file]
            test_file = folder_path + '/' + file + '/' + file_list[file]
            func(ref_file, test_file,args.debug)
        print('Done!')


        
	



                        
                    
