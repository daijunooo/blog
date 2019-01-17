---
title: 一次烧脑的代码重构实践
date: 2017-3-23
categories: php
tag: php 代码优化
---

# 背景故事

- 公司要开发一个爬虫，每天自动质检设备安装完成并正常运行的工单，帮助运营人员提高工作效率。
同事已经开发好了部分功能，后续的工作交到了我这里，为了快同事将整个逻辑基本是用面向过程的方式实现的。
考虑到后续的新功能需求可能还会有，我决定用 oop 方式重构代码。

### 原始代码（主方法）

``` php
public function getWorkOrder()
{
    set_time_limit(0);
    $cookie_file = $this->loginGsp();
    $phpsessid = $this->getCodeData();

    $orgarr = array(118008, 118009); //企业客户销售，智能管车销售,118008, 118009
    $impltype = array(1, 2, 3, 4, 5); //安装，拆机，移机，换机，检修
    $impltitle = array('安装', '拆机', '移机', '换机', '检修');
    $qualitystatus = array(0, 3);//质检结果，未质检0，质检延期3
    $params['back_status'] = 1;//回单证明，有
    $params['s_time'] = 1;
    $params['limit'] = 100; //每页个数
    $params['workorder_status'] = 6; //工单状态，审核通过
    $qualitypass = $qualinotpass = $notcare = $notdeal = $implenum = 0;
    $jobnos = array();
    foreach ($orgarr as $k1 => $org) {
        foreach ($impltype as $k2 => $itype) {
            foreach ($qualitystatus as $k3 => $qstatus) {
                $sum = 0;
                do {
                    $params['customerOrg'] = $org;
                    $params['implement_type'] = $itype;
                    $params['quality_test_status'] = $qstatus;
                    $params['start'] = $sum;
                    $result = $this->postRequest($params, self::$url['workorder_search']);//查询实施工单
                    $m = 0;
                    while (!$result && $m <= 10) {
                        $m++;
                        $result = $this->postRequest($params, self::$url['workorder_search']);//查询实施工单，第一次查不到，重新执行
                    }

                    $result = json_decode($result);
                    if (!empty($result) && $result->data) {
                        foreach ($result->data as $key => $val) {
                            //判断工程师上门时间，需要是3天凌晨0点之前才做处理
                            $cptime = strtotime(date('Y-m-d 00:00:00', strtotime('-3 days')));
                            // 先不处理年审的工单
                            if (!empty($val->home_to_time) && strtotime($val->home_to_time) < $cptime) {
                                $param['jobNo'] = $val->job_no;
                                $res = $this->postRequest($param, self::$url['getImplementInfo']); //查看工单详情
                                $n = 0;
                                while (!$res && $n <= 10) {
                                    $n++;
                                    $res = $this->postRequest($param, self::$url['getImplementInfo']); //查看工单详情，第一次查不到，重新执行
                                }
                                $res = json_decode($res);
                                if ($res && $res->data) {
                                    $detail = $res->data;
                                    if ($itype == 2) {
                                        // 拆机情况，质检通过
                                        $jobnos[] = $val->job_no;
                                        $qualitypass++;
                                        $this->log('质检通过', $val->job_no, $impltitle[$itype - 1] . '质检通过', 'QualityPassed');
                                    } else {
                                        if ($itype == 1 || $itype == 4) {
                                            // 安装换机用新设备
                                            $gspparams['ids'] = $val->gpsno_new;
                                        } else if ($itype == 3 || $itype == 5) {
                                            // 检修移机用老设备
                                            $gspparams['ids'] = $val->gpsno;
                                        }
                                        $gspparams['limit'] = 20;
                                        $gspparams['start'] = 0;
                                        $gspparams['service_gsp'] = 1;
                                        $gpsres = $this->postRequest($gspparams, self::$url['gps_search']);//查询设备IMEI号
                                        $h = 0;
                                        while (!$gpsres && $h <= 10) {
                                            $h++;
                                            $gpsres = $this->postRequest($gspparams, self::$url['gps_search']);//查询设备IMEI号，第一次查不到，重新执行
                                        }
                                        $gpsres = json_decode($gpsres);

                                        if ($gpsres && !empty($gpsres->data)) {
                                            $curparam['gpsid'] = $gpsres->data[0]->gpsid;
                                            $curparam['gpsno'] = $gspparams['ids'];
                                            $curparam['intstat'] = 1;
                                            $curparam['from'] = date('Y-m-d 00:00:00', strtotime('-2 days'));
                                            $curparam['to'] = date('Y-m-d H:i:s', time());
                                            $curres = $this->postRequest($curparam, self::$url['gpsRecent']);//查询定位历史
                                            $curres = json_decode($curres);
                                            if (count($curres) > 1) {
                                                $sumdistance = 0;
                                                $countdistance = 0;
                                                for ($i = 1; $i < count($curres); $i++) {
                                                    if (intval($curres[$i]->distance) >= 500000) {
                                                        $countdistance += intval($curres[$i]->distance);
                                                    }
                                                    $sumdistance += intval($curres[$i]->distance);
                                                }
                                                if ($sumdistance >= 1000000 && $countdistance / $sumdistance < 0.05) {
                                                    $implres = $this->implementDetail($detail);//是否安装EMS，冷链，油感
                                                    $contain = $this->containStr($val->serv_remark);//判断是否包含关键字
                                                    if ($implres == 0 && $contain == 0) {
                                                        $jobnos[] = $val->job_no;
                                                        $qualitypass++;
                                                        $this->log('质检通过', $val->job_no, $impltitle[$itype - 1] . '质检通过，在线', 'QualityPassed');
                                                    } else if ($implres == 0 && $contain == 1) {
                                                        $check = $this->postRequest($val->gpsno_new, self::$url['check']);
                                                        $check = json_decode($check);
                                                        if (isset($check->data->message)) {
                                                            $jobnos[] = $val->job_no;
                                                            $qualitypass++;
                                                            $this->log('质检通过', $val->job_no, $impltitle[$itype - 1] . '质检通过，在线', 'QualityPassed');
                                                        } else {
                                                            $notdeal++;
                                                            $this->log('未处理', $val->job_no, $impltitle[$itype - 1] . $check->data[0]->abnormal_type, 'NotDeal');
                                                        }
                                                    } else {
                                                        $implenum++;
                                                    }
                                                } else if ($sumdistance == 0) {
                                                    $curparam['from'] = date('Y-m-d 00:00:00', strtotime('-10 days'));
                                                    $curres0 = $this->postRequest($curparam, self::$url['gpsRecent']);//查询定位历史
                                                    $curres0 = json_decode($curres0);
                                                    $sumdistance0 = 0;
                                                    for ($i = 1; $i < count($curres0); $i++) {
                                                        $sumdistance0 += intval($curres0[$i]->distance);
                                                    }
                                                    if ($sumdistance0 == 0) {
                                                        $notdeal++;
                                                        $this->log('未处理', $val->job_no, $impltitle[$itype - 1] . '设备已静止10天以上', 'NotDeal');
                                                    } else {
                                                        $notcare++;
                                                        $this->log('暂不需处理', $val->job_no, $impltitle[$itype - 1] . '设备一直静止，总距离为0', 'NoNeedToDeal');
                                                    }
                                                } else if ($sumdistance > 0 && $sumdistance < 1000000 && $countdistance / $sumdistance < 0.05) {
                                                    $notcare++;
                                                    $this->log('暂不需处理', $val->job_no, $impltitle[$itype - 1] . '设备，两天内行驶距离小于10公里', 'NoNeedToDeal');
                                                } else {
                                                    $qualinotpass++;
                                                    $this->log('质检未通过', $val->job_no, $impltitle[$itype - 1] . '质检未通过，定位异常，异常距离' . ($countdistance / 100000) . '，总距离' . ($sumdistance / 100000), 'QualityNotPass');
                                                }
                                            } else {
                                                $notdeal++;
                                                $this->log('未处理', $val->job_no, $impltitle[$itype - 1] . '设备无定位历史或已离线超过2天', 'NotDeal');
                                            }
                                        } else {
                                            $notdeal++;
                                            $this->log('未处理', $val->job_no, $impltitle[$itype - 1] . '查不到设备IMEI信息', 'NotDeal');
                                        }
                                    }
                                } else {
                                    $notdeal++;
                                    $this->log('未处理', $val->job_no, $impltitle[$itype - 1] . '无工单详情', 'NotDeal');
                                }
                            }
                        }
                    }
                    $sum += $params['limit'];
                } while (!empty($result) && $sum < $result->total);
            }
        }
    }
    print_r($jobnos);
    //统一设置质检通过
    if (count($jobnos) > 0) {
        foreach ($jobnos as $key => $val) {
            $uparam['quality_test_status'] = 1; // 1为质检通过，2为不通过
            $uparam['nos'] = $val;
            $ures = $this->postRequest($uparam, self::$url['quality']);
            unset($uparam);
        }
    }
    //发送邮件
    $this->sendEmail($qualitypass, $qualinotpass, $notcare, $notdeal, $implenum);
}
```

### 重构后的（主方法）

``` php
public function checkOrder()
{
    foreach ($this->data as $key => &$value) {

        //实施时间距今两天以内的不处理
        $itime = time() - strtotime($value['implement_time']);
        if (!$value['implement_time'] || $itime < 86400 * 2) {
            unset($this->data[$key]);
            continue;
        }

        //serv_type 实施类型 1安装 2拆机 3移机 4换机 5检修 (拆机直接质检通过)
        if ($value['serv_type'] == 2) {
            $this->check[] = $value['job_no'];
            $value['checkresult'] = 1;
            $value['checkcommon'] = '拆机';
            continue;
        }

        //查询工单详情
        for ($i = 0; $i < 5; $i++) {
            $param['jobNo'] = $value['job_no'];
            $res = $this->postRequest($param, self::$url['getImplementInfo']);
            $res = json_decode($res, true);
            if ($value['devicedetail'] = $res['data']) break;
        }
        if (!$value['devicedetail']) {
            $value['checkresult'] = 0;
            $value['checkcommon'] = '查不到工单详情';
            continue;
        }

        //以下是主要业务逻辑，可以通过注释任意组合质检项，后续新需求也是堆积木一样开发
        //复杂问题模块化处理，避免在秃头的道路上越走越远 😂

        //定位
        $this->checkLocation($value);

        //年审
        $this->checkYear($value);

        //EMS
        $this->checkEms($value);

        //冷链
        $this->checkCold($value);

        //是否质检通过判断
        $this->check($value);

        //写入数据库
        $this->save($value);

    }

    //质检操作
    $this->doCheck();

    //推送邮件
    $this->sendEmail();
}
```

### 后记

#### 如何组织代码的沉思

``` php
//常规写法（伪代码）
function see($人) {
    if (这个人有眼) {
        if (这个人眼没瞎) {
            if (这个人眼是睁开的) {
                return '这个人是能看见的 ：）';
            }
        }
    }
}

/**
 * 稍优化一下（伪代码）
 * 这么写已经很不错了，但是还有优化的空间
 */
function see($人) {
    if (这个人有眼 && 这个人眼没瞎 && 这个人眼是睁开的) {
        return '这个人是能看见的 ：）';
    }
}

/**
 * 稍优化二下（伪代码）
 * 看上去变的更复杂了，但是却解耦了判断条件，当有新的判断加入是友好的，或者对每种判断增加提示信息
 * 也是友好的，我个人推荐减少代码逻辑复杂度，各种条件嵌套不超过2层。
 */
function see($人) {
    if (！这个人有眼) {
        return false;
    }
    if (！这个人眼没瞎) {
        return false;
    }
    if (！这个人眼是睁开的) {
        return false;
    }

    return '这个人是能看见的 ：）';
}

/**
 * 通用套路
 * 一下是针对复杂逻辑的，一般一层嵌套是可以接受的，除非你严重强迫症
 */
function see($人) {
    //不推荐：无形中就增加了一层if嵌套，当条件增多时不易维护
    if (条件成立) {
        我要处理这件事;
    }

    //改为这样：好处是把处理逻辑放到了if外，减少了嵌套，即使条件增多也像搭积木一样
    if (条件不成立) {
        跳出此方法;
    }
    在这里处理;
}
```

# 总结
- 好的coder会写很详细的注释，更好的coder不用写太多注释（完美抽象现实，面向对象方式实现）。
- 好的coder代码风格鲜明，更好的coder你不知道他是谁（所有人的代码像是同一个人写出来的）。