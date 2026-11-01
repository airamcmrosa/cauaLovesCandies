/// Single source of truth for Cauã's reaction timings (seconds).
///
/// Starting points to be tuned in playtest; no other file may hardcode them.
library;

/// Duration of each of the three chew frames.
const double kChewStep = 0.16;

/// Number of chew frames (eyes open, half, shut).
const int kChewSteps = 3;

/// Extra time after the last chew frame before returning to idle.
const double kReactionRecover = 0.12;

/// Total chew duration: `kChewStep * kChewSteps + kReactionRecover` (0.60 s).
const double kChewTotal = kChewStep * kChewSteps + kReactionRecover;

/// How long the "eca" face is held.
const double kEcaHold = 0.60;

/// Slack between the end of a reaction and the next item arrival.
const double kArrivalSlack = 0.20;

/// Minimum time between two consecutive item arrivals at the mouth (0.80 s).
const double kMinArrivalGap =
    (kChewTotal > kEcaHold ? kChewTotal : kEcaHold) + kArrivalSlack;

/// Safety margin added to [kMinArrivalGap] when spacing spawns, so frame
/// quantization (a spawn and a decision each land on a frame) never breaks it.
const double kArrivalGapMargin = 0.06;
