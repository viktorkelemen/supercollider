// Kaitlyn Aurelia Smith inspired organic pluck sequence
// Slow, breathing arpeggios with selective shimmer delays (1 octave up)

(
// Main plucks with varied shimmer delays
s.sendBundle(0.0, [\s_new, \organicPluck, -1, 0, 0, \freq, 220, \amp, 0.15, \decay, 4.5, \brightness, 0.4]);
s.sendBundle(0.3, [\s_new, \organicPluck, -1, 0, 0, \freq, 440, \amp, 0.05, \decay, 2.5, \brightness, 0.5]); // short delay shimmer
s.sendBundle(0.6, [\s_new, \organicPluck, -1, 0, 0, \freq, 330, \amp, 0.12, \decay, 4, \brightness, 0.5]);
s.sendBundle(1.4, [\s_new, \organicPluck, -1, 0, 0, \freq, 440, \amp, 0.1, \decay, 3.5, \brightness, 0.55]);
s.sendBundle(2.0, [\s_new, \organicPluck, -1, 0, 0, \freq, 880, \amp, 0.04, \decay, 2, \brightness, 0.52]); // long delay shimmer
s.sendBundle(2.5, [\s_new, \organicPluck, -1, 0, 0, \freq, 880, \amp, 0.02, \decay, 1.5, \brightness, 0.48]);
s.sendBundle(2.2, [\s_new, \organicPluck, -1, 0, 0, \freq, 495, \amp, 0.09, \decay, 3.8, \brightness, 0.52]);
s.sendBundle(3.2, [\s_new, \organicPluck, -1, 0, 0, \freq, 660, \amp, 0.07, \decay, 4.2, \brightness, 0.58]);
s.sendBundle(3.7, [\s_new, \organicPluck, -1, 0, 0, \freq, 1320, \amp, 0.03, \decay, 1.8, \brightness, 0.5]); // medium delay shimmer
s.sendBundle(4.2, [\s_new, \organicPluck, -1, 0, 0, \freq, 550, \amp, 0.08, \decay, 4, \brightness, 0.48]);
s.sendBundle(5.0, [\s_new, \organicPluck, -1, 0, 0, \freq, 1100, \amp, 0.035, \decay, 2.2, \brightness, 0.46]); // long delay shimmer
s.sendBundle(5.0, [\s_new, \organicPluck, -1, 0, 0, \freq, 392, \amp, 0.11, \decay, 4.5, \brightness, 0.45]);
s.sendBundle(5.25, [\s_new, \organicPluck, -1, 0, 0, \freq, 784, \amp, 0.045, \decay, 2.2, \brightness, 0.48]); // short delay shimmer
s.sendBundle(5.9, [\s_new, \organicPluck, -1, 0, 0, \freq, 294, \amp, 0.13, \decay, 5, \brightness, 0.42]);
s.sendBundle(6.9, [\s_new, \organicPluck, -1, 0, 0, \freq, 588, \amp, 0.04, \decay, 2.8, \brightness, 0.44]); // very long delay shimmer
s.sendBundle(6.8, [\s_new, \organicPluck, -1, 0, 0, \freq, 370, \amp, 0.1, \decay, 4.2, \brightness, 0.5]);
s.sendBundle(7.3, [\s_new, \organicPluck, -1, 0, 0, \freq, 740, \amp, 0.04, \decay, 2, \brightness, 0.48]); // medium delay shimmer
s.sendBundle(7.8, [\s_new, \organicPluck, -1, 0, 0, \freq, 247, \amp, 0.14, \decay, 5.5, \brightness, 0.38]);
s.sendBundle(8.6, [\s_new, \organicPluck, -1, 0, 0, \freq, 494, \amp, 0.05, \decay, 2.5, \brightness, 0.44]); // long delay shimmer
)
