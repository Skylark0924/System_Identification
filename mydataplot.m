u=current_num;
speed_test=lsim(ss1,u,time);
% angle_test=lsim(ss2,u,time);
figure
% plot(time,speed); hold on;
plot(time,anglespeed_num);
figure
% plot(time,angle); hold on;
plot(time,angle_num);

input1=[time',anglespeed_num];
input2=[time',angle_num];