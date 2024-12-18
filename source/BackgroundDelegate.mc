import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

(:background)
class BackgroundDelegate extends ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        System.println("onTemporalEvent");
        var bgData = [];

        for (var i = 0; i < data.bgExperiments.size(); i++) {
            if (timeUntilTrigger(data.bgExperiments[i]) == 0) {
                bgData.add(i);
            }
        }

        if (bgData.size() > 0) {
            Background.requestApplicationWake("GarminQ - Question Available!");
            Background.exit(bgData);
            Background.registerForTemporalEvent(new Duration(5 * 60));
        }
    }

    function timeUntilTrigger(bgEx as BgExperiment) {
        var now = Time.now().value();
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        // Georgian day_of_week: (Sun = 1, Mon = 2, Tue = 3..)
        // Our day_of_week: (Mon = 0, Tue = 1, Wed = 2..)
        var day_of_week = info.day_of_week == 1 ? 6 : info.day_of_week - 2;

        // In minutes
        var curDelta = (now - bgEx[EX_BG_LAST_TRIGGER]) / 60;
        var neededDelta = data.distMode == 0
                            ? normalVariate(bgEx[EX_BG_LAST_TRIGGER], bgEx[EX_GAP], bgEx[EX_GAP] / 5)
                            : expoVariate(bgEx[EX_BG_LAST_TRIGGER], 1.0 / bgEx[EX_GAP]);
        var snoozeDelta = 0;

        // Add hour + minutes to snooze if we're outside the selected hours
        if (bgEx[EX_START_H] > info.hour || bgEx[EX_END_H] < info.hour) {
            snoozeDelta += (60 - info.min) + ((bgEx[EX_START_H] + 24 - info.hour) % 24 - 1) * 60;
        }

        // Add days to snooze if we have selected a specific day to trigger
        if (bgEx[EX_DAYS] > 0) {
            if (bgEx[EX_DAYS] < 8 && day_of_week != bgEx[EX_DAYS]
            || (bgEx[EX_DAYS] == 9 && day_of_week < 5)
            || (bgEx[EX_DAYS] == 8 && day_of_week > 4)) {
                var nextDay = bgEx[EX_DAYS] < 8 ? bgEx[EX_DAYS] : bgEx[EX_DAYS] == 8 ? 0 : 5;
                snoozeDelta += ((nextDay + 7 - day_of_week) % 7 - 1) * 86400;
            }
        }

        // Snooze if we're in an activity
        if (!data.inActivity && snoozeDelta == 0 && Activity.getActivityInfo() != null && Activity.getActivityInfo().startTime != null) {
            snoozeDelta += 5;
        }

        // System.println(curDelta + " / " + neededDelta);
        return (curDelta > neededDelta ? 0 : neededDelta) + snoozeDelta;
    }

    // From: https://github.com/python/cpython/blob/85af78996117dbe8ad45716633a3d6c39ff7bab2/Lib/random.py#L534
    // mu = Mean, sigma = Standard Deviation
    private static var NV_MAGICCONST as Float = 1.71552776992;
    function normalVariate(seed, mu, sigma) {
        while (true) {
            var u1 = mulberry32(seed);
            var u2 = 1.0 - mulberry32(seed + 1);
            var z = NV_MAGICCONST * (u1 - 0.5) / u2;
            var zz = z * z / 4.0;
            if (zz <= -Math.ln(u2)) {
                return mu + z * sigma;
            }
        }
        return null; // Invalid Path, should always return from the while(true) block
    }

    // From: https://github.com/python/cpython/blob/85af78996117dbe8ad45716633a3d6c39ff7bab2/Lib/random.py#L603
    function expoVariate(seed, lambda) {
        return -Math.ln(1.0 - mulberry32(seed)) / lambda;
    }

    // Math.srand() and Math.rand() doesn't do the one job its supposed to do.
    // From: https://gist.github.com/tommyettinger/46a874533244883189143505d203312c
    function mulberry32(seed) {
        var z = (seed.toNumber() + 0x6D2B79F5);
        z = (z ^ (z >> 15)) * (z | 1);
        z ^= z + (z ^ (z >> 7)) * (z | 61);
        return (z ^ (z >> 14)).abs() / 2147483647.0;
    }
}