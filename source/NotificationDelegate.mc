import Toybox.Activity;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.WatchUi;
import Toybox.Time;

class NotificationDelegate extends BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onPreviousPage() as Boolean {
        NotificationView.done = false;
        if (NotificationView.value < NotificationView.ex[EX_INPUT].size() - 1) {
            NotificationView.value++;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onNextPage() as Boolean {
        NotificationView.done = false;
        if (NotificationView.value > 0) {
            NotificationView.value--;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() as Boolean {
        if (NotificationView.done) {
            var activity = null;
            var battery = null;
            var stress = null;
            // Check if an activity is active (surely theres a better way..?)
            if (Activity.getActivityInfo() != null && Activity.getActivityInfo().timerState != null
                && Activity.getActivityInfo().timerState != 0 && Activity has :getProfileInfo) {
                activity = Activity.getProfileInfo().name;
            }

            if (SensorHistory has :getBodyBatteryHistory && SensorHistory.getBodyBatteryHistory(null).next() != null) {
                battery = SensorHistory.getBodyBatteryHistory(null).next().data;
            }

            if (SensorHistory has :getStressHistory && SensorHistory.getStressHistory(null).next() != null) {
                stress = SensorHistory.getStressHistory(null).next().data;
            }

            if (NotificationView.modifying == -1) {
                NotificationView.ex[EX_RECORDS].add([
                    Time.now().value(),
                    NotificationView.value,
                    activity,
                    Sensor.getInfo().heartRate,
                    battery,
                    stress
                ]);
            } else {
                NotificationView.ex[EX_RECORDS][NotificationView.modifying][RE_VALUE] = NotificationView.value;
            }

            data.saveExp();

            // Show all notifications if multiple are queued.
            if (App.bgData.size() > 1) {
                WatchUi.switchToView(new NotificationView(data.experiments[App.bgData[1]], -1), new NotificationDelegate(), WatchUi.SLIDE_IMMEDIATE);
                App.bgData.remove(App.bgData[1]);
            } else {
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
            }
        } else {
            NotificationView.done = true;
        }

        WatchUi.requestUpdate();
        return true;
    }
}
