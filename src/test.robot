*** Settings ***
Library           SSHLibrary
Library           /home/robotTest/src/ExampleLibrary.py
Library           DatabaseLibrary

*** Test Cases ***

登陆ssh终端
    Open Connection    172.21.70.208
    ${output}=    Login    root    root

设置PMT电压
    ${result}=    Execute Command    /mnt/i2c_2631vbb 1240
    ${result}=    Execute Command    /mnt/i2c_2631hv 2440

FPGA参数配置
    ${result}=    Execute Command    cmd /gp/libspiCtrl.so set_fpga_default

脉冲测试
    ${result}=    Execute Command    cmd /gp/libspiCtrl.so read_pluse
    ${dataOut}=    pluse data get    ${result}    pluse data,    result: =
    Should Contain    ${dataOut}    0

能谱测试
    ${result}=    Execute Command    cmd /gp/libspiCtrl.so read_energy
    ${dataOut}=    energy data get    ${result}    energy data,    result: =
    Should Contain    ${dataOut}    0

窗口计数
    ${result}=    Execute Command    cmd /gp/libspiCtrl.so trigger_win
    sleep    1
    ${result}=    Execute Command    cmd /gp/libspiCtrl.so read_win
    ${dataOut}=    win data get    ${result}    win    1111
    Should Contain    ${dataOut}    0

链接数据库
    Connect To Database Using Custom Params    pymysql     database='FLOW_Para',user='root',password='root',host='172.21.70.208',port=3306

数据库查询
    @{result}    Query    select * from FlowMinute;
    Log Many    @{result}

差压/绝压/温度传感器测试
    @{result}    Query    select * from FlowMinute;
    Log Many    @{result}
    ${cmdResult}=    Execute Command    cmd /gp/libiicCtrl.so iic_read_pressure
    read_pressure_sensor     ${cmdResult}    @{result}
    ${cmdResult}=    Execute Command    cmd /gp/libiicCtrl.so iic_read_delta_pressure
    read_delta_pressure_sensor    ${cmdResult}    @{result}
    ${cmdResult}=    Execute Command    cmd /gp/libiicCtrl.so iic_read_pressure_temperature
    read_pressure_temperature_sensor    ${cmdResult}    @{result}

断开数据库
    Disconnect From Database

退出ssh终端
    Close Connection
