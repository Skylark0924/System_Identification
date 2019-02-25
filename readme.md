# 系统辨识及PID参数调节

### 系统辨识

以云台6623电机为例

1. 利用MATLAB生成采样频率为500Hz，幅值为1500，从0Hz到10Hz的扫频信号，并生成为txt文件（程序：sweep_wave_script_txt.m)

   ![current_num1](.\img\current_num1.jpg)

2. 利用生成的扫频信号作为`GMY.Intensity`的输入激励电机转动，使用`J-LINK`代替`ST-LINK`作为`Debugger`，需要在`Settings`中检查一下连接。（[J-Link的SWD接线方式](https://blog.csdn.net/gongyuan073/article/details/19830757)）

   <img src="E:\Academic_information\To_be_a_Roboticist\8.12.00-5.jpg" width="30%">

   <img src="E:\Academic_information\To_be_a_Roboticist\1551061273990.png" width="80%">

   

3. 利用`Jscope`监测电流、角度和角速度输出值。此时电机应该**已经安装好了实际的负载**，因为系统辨识是需要得到该电机在工作状态下的传递函数，用这个数学模型来模拟实际情况，因此**需要在装好的车上进行系统辨识**，并且**要保证电机和所带负载在运动行程中没有受到机械限位的约束**。

   **注意：**电流、角度和角速度对应的变量必须乘1000转化为整形才能被`Jscope`读取

   ```c++
   GMYtarget_int=(int)(GMY.Intensity*1000);
   GMYAngleSpeed_int=(int)(imu.wz*1000);
   GMYAngle_int=(int)(imu.yaw*1000);
   ```

   `Jscope`的配置如下，`Sample Rate`是`500Hz`，因此前面是`2000`；`Elf File`就是我们程序编译生成的`RM_frame.axf`文件：

   <img src="E:\Academic_information\To_be_a_Roboticist\1551072707680.png" width="40%">

   `Jscope`的输出形状大致如下图，蓝色为输入的扫频信号，绿色为角速度值，黄色为角度值：

   ![1551071825317](E:\Academic_information\To_be_a_Roboticist\1551071825317.png)

4. 将`Jscope`的数据导出到CSV中，在Excel 365中用**数据导入**功能，将CSV文件转化为`.xlsx`格式，并在Excel中对数据进行必要的预处理，找出一个合适的测量段范围。例如，在`mydata.m`文件中所用的`0126_1502.xlsx`数据的测量段是`B3083:D15582`，从扫频起点开始，正好是12500个采样值，也就是一次扫频信号的输出结果，其中三列分别是扫频信号、角速度、角度。

   **注意：**此处三列数据均要除以1000，变换回`double`值。

   ![1](E:\MATLABwork\system_identification\1.jpg)

   上图的输出结果和`Jscope`上意义相同，只不过我使用了相反的扫频信号（当时受到了另一侧的机械限位，以后可以直接用正的扫频信号）

5. 打开MATLAB的`System Identification`工具箱。

   - `Import data`中选择`Time domain data`，在弹出的对话框中输入：

     <img src="E:\Academic_information\To_be_a_Roboticist\1551079116700.png" width="40%">

   - `Estimate`中选择`State Space Models`，默认采用四阶的，修改为离散时间，点击`Estimate`，可以得到一份辨识报告，适配度在99.96%左右：

     ![1551079320799](E:\Academic_information\To_be_a_Roboticist\1551079320799.png)

   - 此时`Model Views`中就生成了一个模型`ss1`，将其拖拽到`To Workspace`控件上，即可在工作区看到这个模型，**即为辨识到的系统状态空间表达式**。

   **注意：**可以使用扫频数据和角速度数据按照上述过程也辨识一个模型，用于`mydataplot.m`中进行测试比对。

   

### 结合Simulink调节PID参数

Simulink模型是`test5_RegularPID.slx`文件。其中`ss1`就是刚辨识出来的模型，`input1`是时间和角速度的增广，`input2`是时间和角度的增广，这两个在`mydataplot.m`中生成。该Simulink模型由速度环和位置环组成，位置环的输出作为速度环的输入，将其与实际角速度进行差分。

![1551079903739](E:\Academic_information\To_be_a_Roboticist\1551079903739.png)

- 调节PID参数时，先调节速度环的PID：

  ![1551080530835](E:\Academic_information\To_be_a_Roboticist\1551080530835.png)

- 点击`Tune...`，打开`PID Tuner App`，利用该工具箱调节PID，如下；

  ![1551081431700](E:\Academic_information\To_be_a_Roboticist\1551081431700.png)

- 调节好速度环之后，输出PID参数，点击`Update Block`，即可在`Block Parameters`中看到调整好的PID参数；

- 位置环PID同理；

- 最后输入、输出的Scope如下图（本例前段数据有异常，只要输入输出相似就好）。

  ![1551081111162](E:\Academic_information\To_be_a_Roboticist\1551081111162.png)

得到的速度PID和位置PID写入frame的相应电机PID参数中，即可得到较好的效果，接下来在此数据基础上微调即可。
