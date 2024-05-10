import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

(:background)
class BackgroundDelegate extends ServiceDelegate {

    private static var NV_MAGICCONST = 1.71552776992;

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        System.println("onTemporalEvent");
        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var bgData = [];

        for (var i = 0; i < data.bgExperiments.size(); i++) {
            var ex = data.bgExperiments[i];
            var curDelta = (Time.now().value() - ex[EX_BG_LAST_TRIGGER]) / 60;
            var neededDelta = normalVariate(ex[EX_BG_LAST_TRIGGER], ex[EX_GAP], ex[EX_GAP] / 8);

            System.println("Delta " + curDelta + "/" + neededDelta);
            if (curDelta > neededDelta) {
                // Snooze if were outside the selected timeframe
                if (ex[EX_START_H] > info.hour || ex[EX_END_H] < info.hour
                    || (ex[EX_DAYS] == 9 && info.day_of_week < 5) || (ex[EX_DAYS] == 8 && info.day_of_week > 4)
                    || (ex[EX_DAYS] > 0 && ex[EX_DAYS] < 8 && info.day_of_week == ex[EX_DAYS] - 1)) {
                        ex[EX_BG_LAST_TRIGGER] = Time.now().value();
                        Storage.setValue("bgExperiments", data.bgExperiments);
                        System.println("Snooze " + ex[EX_NAME]);
                        continue;
                }

                bgData.add(i);
            }
        }

        if (bgData.size() > 0) {
            Background.requestApplicationWake("ESM Question Available!");
            Background.exit(bgData);
            Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        }
    }

    // See Also:
    // https://github.com/python/cpython/blob/85af78996117dbe8ad45716633a3d6c39ff7bab2/Lib/random.py#L534
    // mu = Mean, sigma = Standard Deviation
    function normalVariate(seed, mu, sigma) {
        Math.srand(seed);
        while (true) {
            var u1 = Math.rand() / 2147483647.0;
            var u2 = 1.0 - Math.rand() / 2147483647.0;
            var z = NV_MAGICCONST * (u1 - 0.5) / u2;
            var zz = z * z / 4.0;
            if (zz <= -Math.ln(u2)) {
                return mu + z * sigma;
            }
        }
        return null; // Invalid Path, should always return from the while(true) block
    }
}