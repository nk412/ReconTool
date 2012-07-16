plot(interval_one(:,1),interval_one(:,4),'color','red','LineWidth',2);
hold on;
plot(interval_one(:,1),interval_one(:,2));
hold off;
waitforbuttonpress;
plot(interval_one(:,1),interval_one(:,5),'color','red','LineWidth',2);
hold on;
plot(interval_one(:,1),interval_one(:,3));
hold off;
waitforbuttonpress;
hist(interval_one(:,6));

